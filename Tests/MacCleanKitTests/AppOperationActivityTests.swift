import XCTest
@testable import MacCleanKit

final class AppOperationActivityTests: XCTestCase {
    func testNestedOperationsStayBusyUntilAllTokensEnd() async throws {
        let activity = AppOperationActivity()
        let outer = try await activity.begin()
        let inner = try await activity.begin()
        activity.end(inner)
        XCTAssertTrue(activity.isBusy)
        activity.end(inner) // An accidental repeated end cannot clear outer.
        XCTAssertTrue(activity.isBusy)
        activity.end(outer)
        XCTAssertFalse(activity.isBusy)
    }

    func testUpdateLeaseClosesGateAndWaitsForExistingWork() async throws {
        let activity = AppOperationActivity()
        let token = try await activity.begin()
        let updateReady = expectation(description: "update waits for cleanup")
        let updating = Task {
            let ready = await activity.prepareForUpdate()
            XCTAssertTrue(ready)
            XCTAssertFalse(activity.isBusy)
            updateReady.fulfill()
        }
        while !activity.isPreparingUpdate { await Task.yield() }
        XCTAssertTrue(activity.isBusy)
        activity.end(token)
        await fulfillment(of: [updateReady], timeout: 2)
        await updating.value
        XCTAssertTrue(activity.isPreparingUpdate)
        activity.cancelUpdate()
    }

    func testAbortedUpdateDoesNotLaterInstallAfterCleanupEnds() async throws {
        let activity = AppOperationActivity()
        let token = try await activity.begin()
        let updater = Task { await activity.prepareForUpdate() }
        while !activity.isPreparingUpdate { await Task.yield() }
        activity.cancelUpdate()
        let ready = await updater.value
        XCTAssertFalse(ready)
        activity.end(token)
        XCTAssertFalse(activity.isPreparingUpdate)
    }

    func testCancelledUpdateResumesQueuedOperations() async throws {
        let activity = AppOperationActivity()
        let ready = await activity.prepareForUpdate()
        XCTAssertTrue(ready)
        XCTAssertFalse(activity.isBusy)
        let queued = Task { try await activity.begin() }
        // Cancellation works whether the operation has reached begin yet or not.
        activity.cancelUpdate()
        let token = try await queued.value
        XCTAssertTrue(activity.isBusy)
        XCTAssertFalse(activity.isPreparingUpdate)
        activity.end(token)
        XCTAssertFalse(activity.isBusy)
    }

    func testCancelledQueuedOperationReturnsBeforeUpdateReleasesGate() async throws {
        let activity = AppOperationActivity()
        let ready = await activity.prepareForUpdate()
        XCTAssertTrue(ready)
        let cancelled = expectation(description: "queued operation cancels promptly")
        let operation = Task {
            do {
                let token = try await activity.begin()
                activity.end(token)
                XCTFail("Cancelled operation acquired a token")
            } catch is CancellationError {
                cancelled.fulfill()
            } catch { XCTFail("Unexpected error: \(error)") }
        }
        await waitUntil { activity.queuedOperationCount == 1 }
        operation.cancel()
        await fulfillment(of: [cancelled], timeout: 2)
        await operation.value
        XCTAssertEqual(activity.queuedOperationCount, 0)
        XCTAssertFalse(activity.isBusy)
        XCTAssertTrue(activity.isPreparingUpdate)
        activity.cancelUpdate()
        XCTAssertFalse(activity.isBusy, "Cancelled waiter must not become a phantom active token")
    }

    func testCancellationBeforeBeginDoesNotAcquireOrQueue() async throws {
        let activity = AppOperationActivity()
        let operation = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            do {
                let token = try await activity.begin()
                activity.end(token)
                XCTFail("Already cancelled operation acquired a token")
            } catch { XCTAssertTrue(error is CancellationError) }
        }
        await operation.value
        XCTAssertFalse(activity.isBusy)
        XCTAssertEqual(activity.queuedOperationCount, 0)
    }

    func testCancellingWaitingUpdateReleasesQueuedOperationsWithoutWaitingForActiveWork() async throws {
        let activity = AppOperationActivity()
        let active = try await activity.begin()
        let update = Task { await activity.prepareForUpdate() }
        await waitUntil { activity.isPreparingUpdate }
        let operation = Task { try await activity.begin() }
        await waitUntil { activity.queuedOperationCount == 1 }
        update.cancel()
        let ready = await update.value
        XCTAssertFalse(ready)
        let resumed = try await operation.value
        XCTAssertFalse(activity.isPreparingUpdate)
        XCTAssertTrue(activity.isBusy)
        activity.end(resumed)
        XCTAssertTrue(activity.isBusy, "Cancelling an update cannot end someone else's active operation")
        activity.end(active)
        XCTAssertFalse(activity.isBusy)
    }

    func testCancellingOneUpdateCannotOpenAnotherUpdatesGate() async throws {
        let activity = AppOperationActivity()
        let active = try await activity.begin()
        let first = Task { await activity.prepareForUpdate() }
        let second = Task { await activity.prepareForUpdate() }
        await waitUntil { activity.pendingUpdateCount == 2 }
        first.cancel()
        let firstReady = await first.value
        XCTAssertFalse(firstReady)
        XCTAssertTrue(activity.isPreparingUpdate)
        XCTAssertEqual(activity.pendingUpdateCount, 1)
        activity.end(active)
        let secondReady = await second.value
        XCTAssertTrue(secondReady)
        XCTAssertTrue(activity.isPreparingUpdate)
        activity.cancelUpdate()
    }

    func testOperationCancellationRacingWithGateOpeningDoesNotLeakTokens() async throws {
        for _ in 0..<100 {
            let activity = AppOperationActivity()
            _ = await activity.prepareForUpdate()
            let operation = Task {
                do {
                    let token = try await activity.begin()
                    activity.end(token)
                } catch { XCTAssertTrue(error is CancellationError) }
            }
            let opening = Task { activity.cancelUpdate() }
            operation.cancel()
            await operation.value
            await opening.value
            XCTAssertFalse(activity.isBusy)
            XCTAssertEqual(activity.queuedOperationCount, 0)
        }
    }

    private func waitUntil(_ condition: () -> Bool, file: StaticString = #filePath, line: UInt = #line) async {
        let deadline = ContinuousClock.now + .seconds(2)
        while !condition(), ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(1))
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }
}

