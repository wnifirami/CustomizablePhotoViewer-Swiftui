import UIKit
@testable import CustomizedPhotoViewer

// Minimal PhotoViewerPhoto implementation used across all test files.
final class MockPhoto: PhotoViewerPhoto {
    let image: UIImage?
    let attributedCaptionTitle:   NSAttributedString?
    let attributedCaptionSummary: NSAttributedString?
    let attributedCaptionCredit:  NSAttributedString?

    init(image: UIImage? = UIImage(),
         title:   String? = nil,
         summary: String? = nil,
         credit:  String? = nil) {
        self.image = image
        self.attributedCaptionTitle   = title.map   { NSAttributedString(string: $0) }
        self.attributedCaptionSummary = summary.map { NSAttributedString(string: $0) }
        self.attributedCaptionCredit  = credit.map  { NSAttributedString(string: $0) }
    }
}
