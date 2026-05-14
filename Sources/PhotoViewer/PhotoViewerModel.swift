import SwiftUI

@Observable final class PhotoViewerModel {
    var currentIndex: Int
    var showOverlay: Bool = true
    /// True when the current page's scroll view is at minimum (fit-to-screen) zoom.
    /// Gates the pan-to-dismiss gesture so it doesn't fight pinch-zoom.
    var isCurrentPhotoAtMinZoom: Bool = true

    let dataSource:    any PhotoViewerDataSource
    let configuration: PhotoViewerConfiguration

    var currentPhoto: (any PhotoViewerPhoto)? { dataSource.photo(at: currentIndex) }

    init(dataSource: any PhotoViewerDataSource,
         initialIndex: Int,
         configuration: PhotoViewerConfiguration) {
        self.dataSource    = dataSource
        self.currentIndex  = max(0, min(initialIndex, max(0, dataSource.numberOfPhotos - 1)))
        self.configuration = configuration
    }

    func navigationTitle(for photo: any PhotoViewerPhoto) -> String {
        let index = dataSource.index(of: photo) ?? currentIndex
        return configuration.titleProvider?(photo, index, dataSource.numberOfPhotos)
            ?? "\(index + 1) of \(dataSource.numberOfPhotos)"
    }

    func maximumZoomScale(for photo: any PhotoViewerPhoto) -> CGFloat {
        configuration.maximumZoomScaleProvider?(photo) ?? 3.0
    }
}
