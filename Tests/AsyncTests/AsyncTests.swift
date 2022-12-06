import XCTest
@testable import Async

final class AsyncTests: XCTestCase {
    func testExample() async throws {
        @MainActor func run() async -> Int {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                XCTFail(error.localizedDescription)
            }
            return 1
        }

        let async = _Async<Int>()
        async(run)
        try await Task.sleep(nanoseconds: 2_000_000_000)

        XCTAssertEqual(async.value, 1)
        XCTAssertNil(async.error)
        XCTAssertFalse(async.isLoading)
    }
}
