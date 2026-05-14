import XCTest
@testable import CustomizedPhotoViewer

@MainActor
final class PhotoViewerConfigurationTests: XCTestCase {

    // MARK: - Default values (all nil)

    func testDefaultOnWillDismissIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().onWillDismiss)
    }

    func testDefaultOnDidDismissIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().onDidDismiss)
    }

    func testDefaultOnNavigateIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().onNavigate)
    }

    func testDefaultTitleProviderIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().titleProvider)
    }

    func testDefaultCaptionViewProviderIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().captionViewProvider)
    }

    func testDefaultLoadingViewProviderIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().loadingViewProvider)
    }

    func testDefaultReferenceViewProviderIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().referenceViewProvider)
    }

    func testDefaultMaximumZoomScaleProviderIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().maximumZoomScaleProvider)
    }

    func testDefaultLongPressHandlerIsNil() {
        XCTAssertNil(PhotoViewerConfiguration().longPressHandler)
    }

    // MARK: - Value semantics

    func testMutatingCopyDoesNotAffectOriginalOnWillDismiss() {
        let original = PhotoViewerConfiguration()
        var copy = original
        copy.onWillDismiss = {}
        XCTAssertNil(original.onWillDismiss)
    }

    func testMutatingCopyDoesNotAffectOriginalTitleProvider() {
        let original = PhotoViewerConfiguration()
        var copy = original
        copy.titleProvider = { _, _, _ in "custom" }
        XCTAssertNil(original.titleProvider)
    }

    func testMutatingCopyDoesNotAffectOriginalLongPressHandler() {
        let original = PhotoViewerConfiguration()
        var copy = original
        copy.longPressHandler = { _ in true }
        XCTAssertNil(original.longPressHandler)
    }

    // MARK: - Closures fire correctly

    func testOnWillDismissFiresWhenCalled() {
        var fired = false
        var configuration = PhotoViewerConfiguration()
        configuration.onWillDismiss = { fired = true }
        configuration.onWillDismiss?()
        XCTAssertTrue(fired)
    }

    func testOnDidDismissFiresWhenCalled() {
        var fired = false
        var configuration = PhotoViewerConfiguration()
        configuration.onDidDismiss = { fired = true }
        configuration.onDidDismiss?()
        XCTAssertTrue(fired)
    }

    func testTitleProviderReturnsExpectedValue() {
        var configuration = PhotoViewerConfiguration()
        configuration.titleProvider = { _, index, total in "\(index + 1) / \(total)" }
        let result = configuration.titleProvider?(MockPhoto(), 2, 5)
        XCTAssertEqual(result, "3 / 5")
    }

    func testMaximumZoomScaleProviderReturnsExpectedValue() {
        var configuration = PhotoViewerConfiguration()
        configuration.maximumZoomScaleProvider = { _ in 5.0 }
        let result = configuration.maximumZoomScaleProvider?(MockPhoto())
        XCTAssertEqual(result, 5.0)
    }

    func testLongPressHandlerReturnsTrueWhenHandled() {
        var configuration = PhotoViewerConfiguration()
        configuration.longPressHandler = { _ in true }
        XCTAssertEqual(configuration.longPressHandler?(MockPhoto()), true)
    }

    func testLongPressHandlerReturnsFalseWhenNotHandled() {
        var configuration = PhotoViewerConfiguration()
        configuration.longPressHandler = { _ in false }
        XCTAssertEqual(configuration.longPressHandler?(MockPhoto()), false)
    }
}
