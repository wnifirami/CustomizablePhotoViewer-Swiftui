import SwiftUI

/// One page inside the viewer. Owns ZoomableScrollView, handles loading state,
/// image-updated notifications, and long-press copy.
struct PhotoPageView: View {
    let photo: any PhotoViewerPhoto
    var model: PhotoViewerModel

    @State private var displayedImage: UIImage?
    @State private var isAtMinimumZoom: Bool = true

    var body: some View {
        ZStack {
            Color.black
            if let image = displayedImage {
                ZoomableScrollView(
                    image: image,
                    maximumZoomScale: model.maximumZoomScale(for: photo),
                    isAtMinimumZoom: $isAtMinimumZoom,
                    onSingleTap: toggleOverlay,
                    onLongPress: handleLongPress)
            } else {
                loadingView
            }
        }
        .onAppear(perform: loadImage)
        .onReceive(
            NotificationCenter.default.publisher(for: .photoViewerPhotoImageUpdated)
        ) { note in
            guard note.object as AnyObject === photo as AnyObject else { return }
            loadImage()
        }
        .onChange(of: isAtMinimumZoom) { _, newValue in
            if isCurrentPage { model.isCurrentPhotoAtMinZoom = newValue }
        }
        .onChange(of: model.currentIndex) { _, _ in
            if isCurrentPage { model.isCurrentPhotoAtMinZoom = isAtMinimumZoom }
        }
    }

    private var isCurrentPage: Bool {
        model.dataSource.index(of: photo) == model.currentIndex
    }

    private func loadImage() {
        displayedImage = photo.imageData.flatMap { UIImage(data: $0) }
            ?? photo.image
            ?? photo.placeholderImage
    }

    private func toggleOverlay() {
        withAnimation(.easeInOut(duration: 0.2)) { model.showOverlay.toggle() }
    }

    private func handleLongPress() {
        let handled = model.configuration.longPressHandler?(photo) ?? false
        if !handled, let image = photo.image { UIPasteboard.general.image = image }
    }

    @ViewBuilder
    private var loadingView: some View {
        if let custom = model.configuration.loadingViewProvider?(photo) {
            custom
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.5)
        }
    }
}
