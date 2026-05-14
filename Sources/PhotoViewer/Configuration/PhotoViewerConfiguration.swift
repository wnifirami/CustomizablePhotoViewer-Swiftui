import UIKit
import SwiftUI

/// All callbacks and overrides for the photo viewer.
/// Every property is optional — leave nil to use the built-in default.
public struct PhotoViewerConfiguration {

    // MARK: Lifecycle
    public var onWillDismiss: (() -> Void)?
    public var onDidDismiss:  (() -> Void)?
    /// Called every time the viewer pages to a new photo.
    public var onNavigate: ((any PhotoViewerPhoto, Int) -> Void)?

    // MARK: Customisation
    /// Override the nav-bar title string. Nil → default "X of Y".
    public var titleProvider: ((any PhotoViewerPhoto, Int, Int) -> String?)?
    /// Return a custom caption view, or nil for the built-in gradient caption.
    public var captionViewProvider: ((any PhotoViewerPhoto) -> AnyView?)?
    /// Return a custom loading indicator, or nil for the built-in spinner.
    public var loadingViewProvider: ((any PhotoViewerPhoto) -> AnyView?)?
    /// The source UIView (thumbnail) to zoom from/back to on present/dismiss.
    public var referenceViewProvider: ((any PhotoViewerPhoto) -> UIView?)?
    /// Per-photo maximum zoom scale. Nil → 3.0.
    public var maximumZoomScaleProvider: ((any PhotoViewerPhoto) -> CGFloat)?
    /// Return true if the long-press was handled (suppresses copy-to-pasteboard fallback).
    public var longPressHandler: ((any PhotoViewerPhoto) -> Bool)?

    public init() {}
}
