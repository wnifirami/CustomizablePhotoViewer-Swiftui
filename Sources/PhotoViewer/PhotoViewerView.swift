import SwiftUI

public struct PhotoViewerView: View {

    // MARK: Inputs

    let photos:              [any PhotoViewerPhoto]
    @Binding var openIndex:  Int?
    var sourceFrameProvider: (Int) -> CGRect
    var configuration:       PhotoViewerConfiguration = .init()
    @Binding var currentVisibleIndex: Int

    // MARK: Private state

    @State private var currentIndex: Int

    @State private var bgOpacity:    Double  = 0
    @State private var showOverlay:  Bool    = false
    @State private var isFramePhase: Bool
    @State private var heroFrame:    CGRect
    @State private var isDragging:   Bool    = false
    @State private var isAtMinZoom:  Bool    = true
    @State private var dragY:        CGFloat = 0

    // MARK: Init

    public init(photos:              [any PhotoViewerPhoto],
                openIndex:           Binding<Int?>,
                sourceFrameProvider: @escaping (Int) -> CGRect,
                configuration:       PhotoViewerConfiguration = .init(),
                currentVisibleIndex: Binding<Int>) {

        self.photos               = photos
        self._openIndex           = openIndex
        self.sourceFrameProvider  = sourceFrameProvider
        self.configuration        = configuration
        self._currentVisibleIndex = currentVisibleIndex

        let initialIndex = openIndex.wrappedValue ?? 0
        _currentIndex = State(wrappedValue: initialIndex)

        // Seed hero at the thumbnail frame so the very first rendered frame
        // already shows the image at thumbnail position — seamless hand-off.
        let thumbnailFrame = sourceFrameProvider(initialIndex)
        _heroFrame    = State(wrappedValue: thumbnailFrame)
        _isFramePhase = State(wrappedValue: true)
    }

    // MARK: Body

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea().opacity(bgOpacity)
            photoContent
            // Always in the tree so safeTop resolves on first render (before the
            // overlay is needed). Glitch-free appearance: just an opacity change.
            HeroOverlayView(
                photos:        photos,
                currentIndex:  currentIndex,
                configuration: configuration,
                onClose:       close
            )
            .opacity(showOverlay ? 1 : 0)
            .allowsHitTesting(showOverlay)
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .transition(.identity)
        .simultaneousGesture(panGesture)
        .onAppear(perform: animateIn)
    }

    // MARK: - Photo content

    @ViewBuilder
    private var photoContent: some View {
        ZStack {
            // Always in tree so ZoomableScrollView completes its first UIKit
            // layout pass during the frame animation. When isFramePhase flips
            // the image is already painted — no post-animation flash.
            interactivePages
                .opacity((!isFramePhase && !isDragging) ? 1 : 0)
                .allowsHitTesting(!isFramePhase && !isDragging)

            // Frame-animated scaledToFill hero — used for both open and close.
            // Animating heroFrame from thumbnail → scaledToFitRect (open) or
            // scaledToFitRect → thumbnail (close) gives a perfect match with
            // the scaledToFill thumbnail at the start and end of each animation.
            if isFramePhase {
                frameHero
                    .transition(.identity)
            }

            // Drag-to-dismiss hero (scaledToFit, follows finger vertically).
            if isDragging {
                heroImage
                    .offset(y: dragY)
                    .scaleEffect(dragScale, anchor: .center)
                    .transition(.identity)
            }
        }
        .transition(.identity)
    }

    @ViewBuilder
    private var frameHero: some View {
        if let image = image(at: currentIndex) {
            let screen = UIScreen.main.bounds
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: heroFrame.width, height: heroFrame.height)
                .clipped()
                .offset(x: heroFrame.midX - screen.width  / 2,
                        y: heroFrame.midY - screen.height / 2)
        }
    }

    @ViewBuilder
    private var heroImage: some View {
        if let image = image(at: currentIndex) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }

    private var interactivePages: some View {
        TabView(selection: $currentIndex) {
            ForEach(photos.indices, id: \.self) { index in
                ZStack {
                    Color.clear
                    if let image = image(at: index) {
                        ZoomableScrollView(
                            image: image,
                            maximumZoomScale: configuration.maximumZoomScaleProvider?(photos[index]) ?? 3.0,
                            isAtMinimumZoom: zoomBinding(for: index),
                            onSingleTap: {
                                withAnimation(.easeInOut(duration: 0.2)) { showOverlay.toggle() }
                            },
                            onLongPress: { handleLongPress(photos[index]) }
                        )
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .onChange(of: currentIndex) { _, newIndex in
            isAtMinZoom         = true
            currentVisibleIndex = newIndex
            if let photo = photos[safe: newIndex] { configuration.onNavigate?(photo, newIndex) }
        }
    }

    // MARK: - Open animation

    private func animateIn() {
        let screen         = UIScreen.main.bounds
        let thumbnailFrame = sourceFrameProvider(currentIndex)
        let targetFrame    = scaledToFitRect(for: currentIndex, in: screen)

        // Pin to thumbnail instantly so the first rendered frame already has the
        // correct starting position (guards against onAppear firing before @State
        // init values commit on some iOS versions).
        var noAnim = Transaction()
        noAnim.disablesAnimations = true
        withTransaction(noAnim) {
            heroFrame    = thumbnailFrame
            bgOpacity    = 0
            isFramePhase = true
            isDragging   = false
        }

        // Expand from thumbnail frame to the natural scaledToFit render rect.
        // Using the animation's completion callback (iOS 17+) so the interactive
        // phase is revealed only after the spring fully settles.
        withAnimation(.spring(response: 0.42, dampingFraction: 0.92)) {
            heroFrame = targetFrame
            bgOpacity = 1
        } completion: {
            var noAnim = Transaction()
            noAnim.disablesAnimations = true
            withTransaction(noAnim) {
                // Seamless switch: scaledToFill in scaledToFitRect == scaledToFit
                // full-screen, so interactivePages appears with no visible jump.
                isFramePhase = false
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                showOverlay = true
            }
        }
    }

    // MARK: - Close

    private func close() {
        configuration.onWillDismiss?()
        showOverlay = false

        let screen         = UIScreen.main.bounds
        let thumbnailFrame = sourceFrameProvider(currentIndex)
        // Start at the scaledToFit render rect so the switch from the interactive
        // scaledToFit viewer → scaledToFill frameHero is invisible (same pixels).
        let startFrame     = scaledToFitRect(for: currentIndex, in: screen)

        var noAnim = Transaction()
        noAnim.disablesAnimations = true
        withTransaction(noAnim) {
            isFramePhase = true
            isDragging   = false
            dragY        = 0
            heroFrame    = startFrame
        }

        withAnimation(.spring(response: 0.42, dampingFraction: 0.92)) {
            heroFrame = thumbnailFrame
            bgOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            openIndex = nil
            configuration.onDidDismiss?()
        }
    }

    // MARK: - Pan-to-dismiss

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard !isFramePhase, isAtMinZoom else { return }
                guard abs(value.translation.height) > abs(value.translation.width) * 1.5 else { return }
                if !isDragging { isDragging = true }
                dragY = value.translation.height
                let progress = min(abs(dragY) / (UIScreen.main.bounds.height / 2), 1)
                bgOpacity = 1 - progress * 0.9
            }
            .onEnded { value in
                guard isDragging else { return }
                guard isAtMinZoom else { snapBack(); return }
                let threshold = UIScreen.main.bounds.height * 50 / 667
                let past = abs(value.translation.height)             > threshold
                        || abs(value.predictedEndTranslation.height) > threshold * 2
                past ? flyOff() : snapBack()
            }
    }

    private func snapBack() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            dragY = 0; bgOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            isDragging = false
        }
    }

    private func flyOff() {
        configuration.onWillDismiss?()
        showOverlay = false

        let capturedDragY  = dragY
        let capturedScale  = dragScale
        let screen         = UIScreen.main.bounds
        let thumbnailFrame = sourceFrameProvider(currentIndex)
        let fitRect        = scaledToFitRect(for: currentIndex, in: screen)

        // Place frameHero at the position the drag hero occupied so the
        // switch from scaledToFit drag hero → scaledToFill frameHero is seamless.
        let scaledWidth  = fitRect.width  * capturedScale
        let scaledHeight = fitRect.height * capturedScale
        let startFrame = CGRect(
            x: screen.width  / 2 - scaledWidth  / 2,
            y: screen.height / 2 + capturedDragY - scaledHeight / 2,
            width:  scaledWidth,
            height: scaledHeight
        )

        var noAnim = Transaction()
        noAnim.disablesAnimations = true
        withTransaction(noAnim) {
            isFramePhase = true
            heroFrame    = startFrame
            isDragging   = false
            dragY        = 0
        }

        withAnimation(.spring(response: 0.42, dampingFraction: 0.92)) {
            heroFrame = thumbnailFrame
            bgOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            openIndex = nil
            configuration.onDidDismiss?()
        }
    }

    // MARK: - Helpers

    private var dragScale: CGFloat {
        1 - min(abs(dragY) / (UIScreen.main.bounds.height / 2), 1) * 0.08
    }

    // The rect (in global/screen coords) that a scaledToFit full-screen image
    // actually occupies. scaledToFill in this same rect == scaledToFit full-screen,
    // so switching between the two modes at this rect is invisible.
    private func scaledToFitRect(for index: Int, in screen: CGRect) -> CGRect {
        guard let image = image(at: index),
              image.size.width > 0, image.size.height > 0 else { return screen }
        let aspect      = image.size.width / image.size.height
        let renderedHeight = min(screen.width / aspect, screen.height)
        let renderedWidth  = min(screen.height * aspect, screen.width)
        return CGRect(x: (screen.width  - renderedWidth)  / 2,
                      y: (screen.height - renderedHeight) / 2,
                      width:  renderedWidth,
                      height: renderedHeight)
    }

    private func image(at index: Int) -> UIImage? {
        guard let photo = photos[safe: index] else { return nil }
        return photo.imageData.flatMap { UIImage(data: $0) } ?? photo.image ?? photo.placeholderImage
    }

    private func zoomBinding(for index: Int) -> Binding<Bool> {
        Binding(
            get: { index == currentIndex ? isAtMinZoom : true },
            set: { if index == currentIndex { isAtMinZoom = $0 } }
        )
    }

    private func handleLongPress(_ photo: any PhotoViewerPhoto) {
        let handled = configuration.longPressHandler?(photo) ?? false
        if !handled, let image = photo.image { UIPasteboard.general.image = image }
    }
}
