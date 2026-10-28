import XCTest
@testable import MacCleanKit

@MainActor
final class SelfUpdatePreparationTests: XCTestCase {
    func testQuitCannotReplaceAnInFlightManualInstallAndAbortCannotCallItsHandler() async {
        let preparation = SelfUpdatePreparation()
        var helperWait: CheckedContinuation<Bool, Never>?
        var installs = 0
        var cancellations = 0
        var secondPreparationStarted = false
        XCTAssertTrue(preparation.start(prepare: {
            await withCheckedContinuation { helperWait = $0 }
        }) { result in
            if case .ready = result { installs += 1 }
            if case .cancelled = result { cancellations += 1 }
        })
        while helperWait == nil { await Task.yield() }
        // Command-Q arrives while manual installation is waiting for helper exit.
        XCTAssertFalse(preparation.start(prepare: {
            secondPreparationStarted = true
            return true
        }) { _ in XCTFail("A duplicate Quit preparation must not own a callback") })
        preparation.cancel()
        XCTAssertEqual(cancellations, 1)
        helperWait?.resume(returning: true)
        await Task.yield()
        XCTAssertEqual(installs, 0, "Aborted manual handler must not run after the helper finally exits")
        XCTAssertFalse(secondPreparationStarted)
        XCTAssertFalse(preparation.isRunning)
    }

    func testStaleCompletionCannotInstallOrClearANewerRetry() async {
        let preparation = SelfUpdatePreparation()
        var oldWait: CheckedContinuation<Bool, Never>?
        var newWait: CheckedContinuation<Bool, Never>?
        var installed: [String] = []
        preparation.start(prepare: { await withCheckedContinuation { oldWait = $0 } }) { result in
            if case .ready = result { installed.append("old") }
        }
        while oldWait == nil { await Task.yield() }
        preparation.cancel()
        preparation.start(prepare: { await withCheckedContinuation { newWait = $0 } }) { result in
            if case .ready = result { installed.append("new") }
        }
        while newWait == nil { await Task.yield() }
        oldWait?.resume(returning: true)
        await Task.yield()
        XCTAssertTrue(preparation.isRunning)
        XCTAssertTrue(installed.isEmpty)
        newWait?.resume(returning: true)
        while preparation.isRunning { await Task.yield() }
        XCTAssertEqual(installed, ["new"])
    }

    func testAbortRepliesToPendingQuitExactlyOnceWithoutWaitingForHelper() async {
        let preparation = SelfUpdatePreparation()
        var helperWait: CheckedContinuation<Bool, Never>?
        var terminationReplies: [Bool] = []
        preparation.start(prepare: { await withCheckedContinuation { helperWait = $0 } }) { result in
            if case .ready = result { terminationReplies.append(true) }
            else { terminationReplies.append(false) }
        }
        while helperWait == nil { await Task.yield() }
        preparation.cancel()
        preparation.cancel()
        XCTAssertEqual(terminationReplies, [false])
        helperWait?.resume(returning: true)
        await Task.yield()
        XCTAssertEqual(terminationReplies, [false])
    }

    func testFailedPreparationCanBeRetried() async {
        let preparation = SelfUpdatePreparation()
        var failures = 0
        preparation.start(prepare: { false }) { result in
            if case .unavailable = result { failures += 1 }
        }
        while preparation.isRunning { await Task.yield() }
        XCTAssertEqual(failures, 1)
        var installs = 0
        XCTAssertTrue(preparation.start(prepare: { true }) { result in
            if case .ready = result { installs += 1 }
        })
        while preparation.isRunning { await Task.yield() }
        XCTAssertEqual(installs, 1)
    }
}
