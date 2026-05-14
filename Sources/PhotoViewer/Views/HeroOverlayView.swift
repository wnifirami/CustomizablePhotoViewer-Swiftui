import SwiftUI

/// Top nav bar + bottom caption used by PhotoViewerView.
struct HeroOverlayView: View {
    let photos:        [any PhotoViewerPhoto]
    let currentIndex:  Int
    let configuration: PhotoViewerConfiguration
    let onClose:       () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            bottomCaption
        }
        .ignoresSafeArea()
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(alignment: .center) {
            closeButton
            Spacer()
            titleLabel
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 12)
        .padding(.top, safeTop + 4)
        .padding(.bottom, 12)
        .background(
            LinearGradient(colors: [Color.black.opacity(0.55), .clear],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Color.black.opacity(0.45))
                .clipShape(Circle())
        }
    }

    private var titleLabel: some View {
        Group {
            if let photo = photos[safe: currentIndex] {
                let text = configuration.titleProvider?(photo, currentIndex, photos.count)
                    ?? "\(currentIndex + 1) of \(photos.count)"
                Text(text)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: Bottom caption

    @ViewBuilder
    private var bottomCaption: some View {
        if let photo = photos[safe: currentIndex] {
            if let custom = configuration.captionViewProvider?(photo) {
                custom
            } else {
                PhotoCaptionView(photo: photo)
                    .padding(.bottom, safeBottom)
            }
        }
    }

    // MARK: Safe area

    private var safeTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: \.isKeyWindow)?
            .safeAreaInsets.top ?? 47
    }

    private var safeBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 34
    }
}
