import XCTest
@testable import MacCleanKit

final class TimeoutTests: XCTestCase {

    func testReturnsValueWhenOperationFinishesInTime() async throws {
        let value = try await withTimeout(.seconds(1)) { 42 }
        XCTAssertEqual(value, 42)
    }

    func testThrowsTimeoutErrorWhenOperationTooSlow() async {
        do {
            _ = try await withTimeout(.milliseconds(50)) {
                try await Task.sleep(for: .seconds(10))
                return 0
            }
            XCTFail("expected withTimeout to throw before the slow operation finished")
        } catch is TimeoutError {
            // expected
        } catch {
            XCTFail("expected TimeoutError, got \(error)")
        }
    }

    func testThrowsOnTimeEvenWhenOperationIgnoresCancellation() async {
        // Models a collector wedged in a non-cancellable call: the timeout
        // must stop waiting at its budget, not when the operation returns.
        let start = ContinuousClock.now
        do {
            _ = try await withTimeout(.milliseconds(100)) { () async -> Int in
                await withCheckedContinuation { continuation in
                    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                        continuation.resume(returning: 0)
                    }
                }
            }
            XCTFail("expected TimeoutError")
        } catch is TimeoutError {
            // expected
        } catch {
            XCTFail("expected TimeoutError, got \(error)")
        }
        let elapsed = ContinuousClock.now - start
        XCTAssertLessThan(elapsed, .seconds(1), "withTimeout waited \(elapsed) for a non-cancellable operation")
    }

    func testOuterCancellationStopsWaiting() async {
        let task = Task {
            try await withTimeout(.seconds(10)) {
                try await Task.sleep(for: .seconds(10))
                return 0
            }
        }
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("expected cancellation to surface as an error")
        } catch is TimeoutError {
            XCTFail("cancellation must not be reported as a timeout")
        } catch {
            // expected: CancellationError
        }
    }

    func testPropagatesOperationError() async {
        struct Boom: Error {}
        do {
            _ = try await withTimeout(.seconds(1)) { () async throws -> Int in
                throw Boom()
            }
            XCTFail("expected the operation's own error to propagate")
        } catch is Boom {
            // expected: a fast failure surfaces, not a timeout
        } catch {
            XCTFail("expected Boom, got \(error)")
        }
    }
}
