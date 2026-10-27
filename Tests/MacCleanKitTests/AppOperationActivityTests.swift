import XCTest
@testable import MacCleanKit

final class AppOperationActivityTests: XCTestCase {
    func testNestedOperationsStayBusyUntilAllTokensEnd() async {
        let activity = AppOperationActivity()
        let outer = await activity.begin()
        let inner = await activity.begin()
        activity.end(inner)
        XCTAssertTrue(activity.isBusy)
        activity.end(inner) // An accidental repeated end cannot clear outer.
        XCTAssertTrue(activity.isBusy)
        activity.end(outer)
        XCTAssertFalse(activity.isBusy)
    }

    func testUpdateLeaseClosesGateAndWaitsForExistingWork() async {
        let activity = AppOperationActivity()
        let token = await activity.begin()
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

    func testAbortedUpdateDoesNotLaterInstallAfterCleanupEnds() async {
        let activity = AppOperationActivity()
        let token = await activity.begin()
        let updater = Task { await activity.prepareForUpdate() }
        while !activity.isPreparingUpdate { await Task.yield() }
        activity.cancelUpdate()
        let ready = await updater.value
        XCTAssertFalse(ready)
        activity.end(token)
        XCTAssertFalse(activity.isPreparingUpdate)
    }

    func testCancelledUpdateResumesQueuedOperations() async {
        let activity = AppOperationActivity()
        let ready = await activity.prepareForUpdate()
        XCTAssertTrue(ready)
        XCTAssertFalse(activity.isBusy)
        let queued = Task { await activity.begin() }
        // Cancellation works whether the operation has reached begin yet or not.
        activity.cancelUpdate()
        let token = await queued.value
        XCTAssertTrue(activity.isBusy)
        XCTAssertFalse(activity.isPreparingUpdate)
        activity.end(token)
        XCTAssertFalse(activity.isBusy)
    }
}

