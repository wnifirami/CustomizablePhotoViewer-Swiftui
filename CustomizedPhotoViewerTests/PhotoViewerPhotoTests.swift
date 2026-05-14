import XCTest
@testable import CustomizedPhotoViewer

@MainActor
final class PhotoViewerPhotoTests: XCTestCase {

    // MARK: - Protocol default values

    func testDefaultImageDataIsNil() {
        XCTAssertNil(MockPhoto().imageData)
    }

    func testDefaultPlaceholderImageIsNil() {
        let photo = MockPhoto(image: nil)
        XCTAssertNil(photo.placeholderImage)
    }

    func testDefaultCaptionTitleIsNil() {
        XCTAssertNil(MockPhoto().attributedCaptionTitle)
    }

    func testDefaultCaptionSummaryIsNil() {
        XCTAssertNil(MockPhoto().attributedCaptionSummary)
    }

    func testDefaultCaptionCreditIsNil() {
        XCTAssertNil(MockPhoto().attributedCaptionCredit)
    }

    // MARK: - Custom values round-trip

    func testImageIsReturnedWhenProvided() {
        let image = UIImage()
        XCTAssertEqual(MockPhoto(image: image).image, image)
    }

    func testNilImageIsReturnedWhenNilProvided() {
        XCTAssertNil(MockPhoto(image: nil).image)
    }

    func testCaptionTitleIsReturnedWhenProvided() {
        let photo = MockPhoto(title: "Kitchen")
        XCTAssertEqual(photo.attributedCaptionTitle?.string, "Kitchen")
    }

    func testCaptionSummaryIsReturnedWhenProvided() {
        let photo = MockPhoto(summary: "Modern lines")
        XCTAssertEqual(photo.attributedCaptionSummary?.string, "Modern lines")
    }

    func testCaptionCreditIsReturnedWhenProvided() {
        let photo = MockPhoto(credit: "© Studio")
        XCTAssertEqual(photo.attributedCaptionCredit?.string, "© Studio")
    }

    // MARK: - Identity

    func testTwoDistinctInstancesAreNotIdentical() {
        let first  = MockPhoto()
        let second = MockPhoto()
        XCTAssertFalse(first === second)
    }

    func testSameInstanceIsIdenticalToItself() {
        let photo = MockPhoto()
        XCTAssertTrue(photo === photo)
    }
}
