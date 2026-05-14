import UIKit

/// A single photo in the viewer. Must be a class (AnyObject) so identity
/// comparisons with === work correctly.
public protocol PhotoViewerPhoto: AnyObject {
    /// Raw bytes — takes priority over `image` (use for animated GIFs).
    var imageData: Data? { get }
    /// Full-resolution still image.
    var image: UIImage? { get }
    /// Shown while the full image is loading.
    var placeholderImage: UIImage? { get }

    var attributedCaptionTitle:   NSAttributedString? { get }
    var attributedCaptionSummary: NSAttributedString? { get }
    var attributedCaptionCredit:  NSAttributedString? { get }
}

// All properties are optional — only implement what you need.
public extension PhotoViewerPhoto {
    var imageData: Data?                             { nil }
    var image: UIImage?                              { nil }
    var placeholderImage: UIImage?                   { nil }
    var attributedCaptionTitle:   NSAttributedString? { nil }
    var attributedCaptionSummary: NSAttributedString? { nil }
    var attributedCaptionCredit:  NSAttributedString? { nil }
}

// Post this (pass the photo as `object`) to refresh a photo that loaded async.
public extension Notification.Name {
    static let photoViewerPhotoImageUpdated = Notification.Name("PhotoViewerPhotoImageUpdated")
}
