import XCTest
@testable import CustomizedPhotoViewer

@MainActor
final class PhotoViewerDataSourceTests: XCTestCase {

    // MARK: - numberOfPhotos

    func testNumberOfPhotosMatchesInputCount() {
        let dataSource = PhotoViewerArrayDataSource(photos: [MockPhoto(), MockPhoto(), MockPhoto()])
        XCTAssertEqual(dataSource.numberOfPhotos, 3)
    }

    func testNumberOfPhotosIsZeroForEmptyInput() {
        let dataSource = PhotoViewerArrayDataSource(photos: [])
        XCTAssertEqual(dataSource.numberOfPhotos, 0)
    }

    func testNumberOfPhotosIsOneForSinglePhoto() {
        let dataSource = PhotoViewerArrayDataSource(photos: [MockPhoto()])
        XCTAssertEqual(dataSource.numberOfPhotos, 1)
    }

    // MARK: - photo(at:)

    func testPhotoAtValidIndexReturnsCorrectPhoto() {
        let first  = MockPhoto()
        let second = MockPhoto()
        let dataSource = PhotoViewerArrayDataSource(photos: [first, second])
        XCTAssertTrue(dataSource.photo(at: 0) === first)
        XCTAssertTrue(dataSource.photo(at: 1) === second)
    }

    func testPhotoAtNegativeIndexReturnsNil() {
        let dataSource = PhotoViewerArrayDataSource(photos: [MockPhoto()])
        XCTAssertNil(dataSource.photo(at: -1))
    }

    func testPhotoAtIndexEqualToCountReturnsNil() {
        let dataSource = PhotoViewerArrayDataSource(photos: [MockPhoto()])
        XCTAssertNil(dataSource.photo(at: 1))
    }

    func testPhotoAtIndexFarAboveCountReturnsNil() {
        let dataSource = PhotoViewerArrayDataSource(photos: [MockPhoto()])
        XCTAssertNil(dataSource.photo(at: 99))
    }

    func testPhotoAtAnyIndexOnEmptyDataSourceReturnsNil() {
        let dataSource = PhotoViewerArrayDataSource(photos: [])
        XCTAssertNil(dataSource.photo(at: 0))
    }

    // MARK: - index(of:)

    func testIndexOfFirstPhotoIsZero() {
        let photo = MockPhoto()
        let dataSource = PhotoViewerArrayDataSource(photos: [photo, MockPhoto()])
        XCTAssertEqual(dataSource.index(of: photo), 0)
    }

    func testIndexOfLastPhotoMatchesCount() {
        let last = MockPhoto()
        let dataSource = PhotoViewerArrayDataSource(photos: [MockPhoto(), MockPhoto(), last])
        XCTAssertEqual(dataSource.index(of: last), 2)
    }

    func testIndexOfUnknownPhotoReturnsNil() {
        let dataSource = PhotoViewerArrayDataSource(photos: [MockPhoto(), MockPhoto()])
        XCTAssertNil(dataSource.index(of: MockPhoto()))
    }

    func testIndexOfPhotoUsesIdentityNotEquality() {
        // Two distinct MockPhoto instances are not the same object.
        let photo = MockPhoto()
        let lookalike = MockPhoto()
        let dataSource = PhotoViewerArrayDataSource(photos: [photo])
        XCTAssertNil(dataSource.index(of: lookalike))
    }

    func testIndexOfPhotoOnEmptyDataSourceReturnsNil() {
        let dataSource = PhotoViewerArrayDataSource(photos: [])
        XCTAssertNil(dataSource.index(of: MockPhoto()))
    }
}
