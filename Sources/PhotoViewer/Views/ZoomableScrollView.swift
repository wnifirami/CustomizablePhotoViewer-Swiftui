import SwiftUI
import UIKit

struct ZoomableScrollView: UIViewRepresentable {
    let image: UIImage
    var maximumZoomScale: CGFloat = 3.0
    @Binding var isAtMinimumZoom: Bool
    var onSingleTap: (() -> Void)?
    var onLongPress: (() -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> ZoomScrollView {
        let scrollView = ZoomScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator   = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom    = true
        scrollView.decelerationRate = .fast
        scrollView.delegate = context.coordinator
        scrollView.contentInsetAdjustmentBehavior = .never

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        context.coordinator.imageView  = imageView
        context.coordinator.scrollView = scrollView

        let doubleTap = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        context.coordinator.doubleTapGestureRecognizer = doubleTap

        let singleTap = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleSingleTap(_:)))
        singleTap.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(singleTap)

        let longPress = UILongPressGestureRecognizer(target: context.coordinator,
                                                     action: #selector(Coordinator.handleLongPress(_:)))
        scrollView.addGestureRecognizer(longPress)

        scrollView.onBoundsChange = { [weak c = context.coordinator] in c?.resetZoom() }
        return scrollView
    }

    func updateUIView(_ scrollView: ZoomScrollView, context: Context) {
        context.coordinator.parent = self
        scrollView.maximumZoomScale = maximumZoomScale
        guard let imageView = context.coordinator.imageView else { return }
        if imageView.image !== image {
            imageView.image = image
            context.coordinator.resetZoom()
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableScrollView
        weak var scrollView: ZoomScrollView?
        weak var imageView:  UIImageView?
        weak var doubleTapGestureRecognizer: UITapGestureRecognizer?

        init(_ parent: ZoomableScrollView) { self.parent = parent }

        func resetZoom() {
            guard let scrollView, let imageView, let image = imageView.image else { return }
            let bounds = scrollView.bounds.size
            guard bounds.width > 0, bounds.height > 0,
                  image.size.width > 0, image.size.height > 0 else { return }

            let minimumScale = min(bounds.width / image.size.width, bounds.height / image.size.height)
            scrollView.minimumZoomScale = minimumScale
            scrollView.maximumZoomScale = max(minimumScale, parent.maximumZoomScale)
            imageView.frame       = CGRect(origin: .zero, size: image.size)
            scrollView.contentSize = image.size
            scrollView.zoomScale   = minimumScale
            centre(imageView, in: scrollView)
            publishMinimumZoom(scrollView)
        }

        private func centre(_ imageView: UIImageView, in scrollView: UIScrollView) {
            let bounds  = scrollView.bounds.size
            let content = scrollView.contentSize
            scrollView.contentInset = UIEdgeInsets(
                top:    max((bounds.height - content.height) / 2, 0),
                left:   max((bounds.width  - content.width)  / 2, 0),
                bottom: max((bounds.height - content.height) / 2, 0),
                right:  max((bounds.width  - content.width)  / 2, 0))
        }

        private func publishMinimumZoom(_ scrollView: UIScrollView) {
            let atMinimum = scrollView.zoomScale <= scrollView.minimumZoomScale + 0.01
            guard atMinimum != parent.isAtMinimumZoom else { return }
            DispatchQueue.main.async { self.parent.isAtMinimumZoom = atMinimum }
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            if let imageView { centre(imageView, in: scrollView) }
            publishMinimumZoom(scrollView)
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            publishMinimumZoom(scrollView)
        }

        @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let scrollView else { return }
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                let point = gestureRecognizer.location(in: imageView)
                scrollView.zoom(to: CGRect(x: point.x - 100, y: point.y - 100, width: 200, height: 200),
                                animated: true)
            }
        }

        @objc func handleSingleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            parent.onSingleTap?()
        }

        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            guard gestureRecognizer.state == .began else { return }
            parent.onLongPress?()
        }
    }
}
