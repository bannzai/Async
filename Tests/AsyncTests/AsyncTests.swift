import XCTest
@testable import Async

private struct TestError: Error { }

final class AsyncTests: XCTestCase {
    func testAsyncAction() async throws {
        do { // success
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

        do { // failure
            @MainActor func run() async throws -> Int {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                throw TestError()
            }

            let async = _Async<Int>()
            async(run)
            try await Task.sleep(nanoseconds: 2_000_000_000)

            XCTAssertEqual(async.value, nil)
            XCTAssertNotNil(async.error)
            XCTAssertFalse(async.isLoading)
        }

        do { // loading
            @MainActor func run() async throws -> Int {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                fatalError()
            }

            let async = _Async<Int>()
            async(run)

            XCTAssertEqual(async.value, nil)
            XCTAssertNil(async.error)
            XCTAssertTrue(async.isLoading)
        }
    }
}
