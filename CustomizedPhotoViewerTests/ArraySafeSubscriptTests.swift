import XCTest
@testable import CustomizedPhotoViewer

@MainActor
final class ArraySafeSubscriptTests: XCTestCase {

    // MARK: - Valid indices

    func testSafeSubscriptAtFirstIndex() {
        let array = [10, 20, 30]
        XCTAssertEqual(array[safe: 0], 10)
    }

    func testSafeSubscriptAtMiddleIndex() {
        let array = [10, 20, 30]
        XCTAssertEqual(array[safe: 1], 20)
    }

    func testSafeSubscriptAtLastIndex() {
        let array = [10, 20, 30]
        XCTAssertEqual(array[safe: 2], 30)
    }

    // MARK: - Out-of-bounds indices

    func testSafeSubscriptBelowBoundsReturnsNil() {
        let array = [10, 20, 30]
        XCTAssertNil(array[safe: -1])
    }

    func testSafeSubscriptAboveBoundsReturnsNil() {
        let array = [10, 20, 30]
        XCTAssertNil(array[safe: 3])
    }

    func testSafeSubscriptFarAboveBoundsReturnsNil() {
        let array = [10, 20, 30]
        XCTAssertNil(array[safe: 100])
    }

    // MARK: - Empty array

    func testSafeSubscriptOnEmptyArrayAtZeroReturnsNil() {
        let array: [Int] = []
        XCTAssertNil(array[safe: 0])
    }

    func testSafeSubscriptOnEmptyArrayAtNegativeReturnsNil() {
        let array: [Int] = []
        XCTAssertNil(array[safe: -1])
    }

    // MARK: - Single-element array

    func testSafeSubscriptOnSingleElementArrayAtZero() {
        let array = [42]
        XCTAssertEqual(array[safe: 0], 42)
    }

    func testSafeSubscriptOnSingleElementArrayAtOneReturnsNil() {
        let array = [42]
        XCTAssertNil(array[safe: 1])
    }
}
