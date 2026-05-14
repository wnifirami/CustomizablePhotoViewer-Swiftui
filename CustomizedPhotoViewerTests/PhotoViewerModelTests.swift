import XCTest
@testable import CustomizedPhotoViewer

@MainActor
final class PhotoViewerModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeModel(photos: [any PhotoViewerPhoto] = [MockPhoto(), MockPhoto(), MockPhoto()],
                           initialIndex: Int = 0,
                           configuration: PhotoViewerConfiguration = .init()) -> PhotoViewerModel {
        PhotoViewerModel(
            dataSource:    PhotoViewerArrayDataSource(photos: photos),
            initialIndex:  initialIndex,
            configuration: configuration
        )
    }

    // MARK: - Initial state

    func testInitialCurrentIndexMatchesInput() {
        let model = makeModel(initialIndex: 1)
        XCTAssertEqual(model.currentIndex, 1)
    }

    func testInitialShowOverlayIsTrue() {
        XCTAssertTrue(makeModel().showOverlay)
    }

    func testInitialIsCurrentPhotoAtMinZoomIsTrue() {
        XCTAssertTrue(makeModel().isCurrentPhotoAtMinZoom)
    }

    // MARK: - Index clamping

    func testInitialIndexClampedToZeroWhenNegative() {
        let model = makeModel(initialIndex: -1)
        XCTAssertEqual(model.currentIndex, 0)
    }

    func testInitialIndexClampedToLastWhenTooHigh() {
        let model = makeModel(photos: [MockPhoto(), MockPhoto()], initialIndex: 99)
        XCTAssertEqual(model.currentIndex, 1)
    }

    func testInitialIndexIsZeroForEmptyDataSource() {
        let model = makeModel(photos: [], initialIndex: 0)
        XCTAssertEqual(model.currentIndex, 0)
    }

    // MARK: - currentPhoto

    func testCurrentPhotoMatchesPhotoAtInitialIndex() {
        let first  = MockPhoto()
        let second = MockPhoto()
        let model  = makeModel(photos: [first, second], initialIndex: 1)
        XCTAssertTrue(model.currentPhoto === second)
    }

    func testCurrentPhotoIsNilForEmptyDataSource() {
        let model = makeModel(photos: [])
        XCTAssertNil(model.currentPhoto)
    }

    func testCurrentPhotoUpdatesWhenCurrentIndexChanges() {
        let first  = MockPhoto()
        let second = MockPhoto()
        let model  = makeModel(photos: [first, second], initialIndex: 0)
        model.currentIndex = 1
        XCTAssertTrue(model.currentPhoto === second)
    }

    // MARK: - State mutations

    func testSettingShowOverlayToFalse() {
        let model = makeModel()
        model.showOverlay = false
        XCTAssertFalse(model.showOverlay)
    }

    func testSettingShowOverlayBackToTrue() {
        let model = makeModel()
        model.showOverlay = false
        model.showOverlay = true
        XCTAssertTrue(model.showOverlay)
    }

    func testSettingIsCurrentPhotoAtMinZoomToFalse() {
        let model = makeModel()
        model.isCurrentPhotoAtMinZoom = false
        XCTAssertFalse(model.isCurrentPhotoAtMinZoom)
    }

    // MARK: - navigationTitle

    func testNavigationTitleDefaultFormatFirstPhoto() {
        let model = makeModel(initialIndex: 0)
        let title = model.navigationTitle(for: model.currentPhoto!)
        XCTAssertEqual(title, "1 of 3")
    }

    func testNavigationTitleDefaultFormatLastPhoto() {
        let photos = [MockPhoto(), MockPhoto(), MockPhoto()]
        let model  = makeModel(photos: photos, initialIndex: 2)
        let title  = model.navigationTitle(for: model.currentPhoto!)
        XCTAssertEqual(title, "3 of 3")
    }

    func testNavigationTitleUsesCustomProviderWhenSet() {
        var configuration = PhotoViewerConfiguration()
        configuration.titleProvider = { _, index, total in "Photo \(index + 1)/\(total)" }
        let model = makeModel(configuration: configuration)
        let title = model.navigationTitle(for: model.currentPhoto!)
        XCTAssertEqual(title, "Photo 1/3")
    }

    func testNavigationTitleFallsBackToDefaultWhenProviderReturnsNil() {
        var configuration = PhotoViewerConfiguration()
        configuration.titleProvider = { _, _, _ in nil }
        let model = makeModel(configuration: configuration)
        let title = model.navigationTitle(for: model.currentPhoto!)
        XCTAssertEqual(title, "1 of 3")
    }

    // MARK: - maximumZoomScale

    func testMaximumZoomScaleDefaultIsThree() {
        let model = makeModel()
        XCTAssertEqual(model.maximumZoomScale(for: model.currentPhoto!), 3.0, accuracy: 0.001)
    }

    func testMaximumZoomScaleUsesCustomProviderWhenSet() {
        var configuration = PhotoViewerConfiguration()
        configuration.maximumZoomScaleProvider = { _ in 6.0 }
        let model = makeModel(configuration: configuration)
        XCTAssertEqual(model.maximumZoomScale(for: model.currentPhoto!), 6.0, accuracy: 0.001)
    }
}
