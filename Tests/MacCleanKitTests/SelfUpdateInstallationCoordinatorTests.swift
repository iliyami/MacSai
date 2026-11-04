import XCTest
@testable import MacCleanKit

@MainActor
final class SelfUpdateInstallationCoordinatorTests: XCTestCase {
    @MainActor
    private final class Fixture {
        let activity = AppOperationActivity()
        var helperStops = 0
        var helperResumes = 0
        var helperResult = true
        var promptsDismissed = 0
        var failures: [Bool] = []
        lazy var coordinator = SelfUpdateInstallationCoordinator(
            activity: activity,
            stopHelper: { [self] in helperStops += 1; return helperResult },
            resumeHelper: { [self] in helperResumes += 1 },
            dismissPrompt: { [self] in promptsDismissed += 1 },
            helperUnavailable: { [self] in failures.append($0) })
    }

    func testBusyOrdinaryQuitDoesNotAcquireGatePromptOrStopHelper() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        let result = f.coordinator.requestTermination(hasPreparedUpdate: false, chooseWait: {
            XCTFail("Ordinary Quit must not present updater UI")
            return true
        }, reply: { _ in XCTFail("Ordinary Quit does not use a deferred reply") })
        XCTAssertEqual(result, .now)
        XCTAssertFalse(f.activity.isPreparingUpdate)
        XCTAssertEqual(f.helperStops, 0)
        f.activity.end(token)
    }

    func testStayReleasesGateWithoutStoppingHelperAndKeepsCurrentOperation() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        var prompt: CheckedContinuation<Bool, Never>?
        var replies: [Bool] = []
        XCTAssertEqual(f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            XCTAssertTrue(f.activity.isPreparingUpdate, "Close gate before displaying choice")
            return await withCheckedContinuation { prompt = $0 }
        }, reply: { replies.append($0) }), .deferred)
        await waitUntil { prompt != nil }
        let queued = Task { try await f.activity.begin() }
        await waitUntil { f.activity.queuedOperationCount == 1 }
        XCTAssertEqual(f.helperStops, 0)
        prompt?.resume(returning: false)
        await waitUntil { !replies.isEmpty }
        XCTAssertEqual(replies, [false])
        XCTAssertFalse(f.activity.isPreparingUpdate)
        XCTAssertFalse(f.coordinator.isPreparingInstallation)
        XCTAssertEqual(f.helperStops, 0)
        let resumed = try await queued.value
        f.activity.end(resumed)
        XCTAssertTrue(f.activity.isBusy)
        f.activity.end(token)
    }

    func testWaitCoalescesQuitAndStopsHelperOnlyAfterExistingWorkEnds() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        var prompt: CheckedContinuation<Bool, Never>?
        var replies: [Bool] = []
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            await withCheckedContinuation { prompt = $0 }
        }, reply: { replies.append($0) })
        await waitUntil { prompt != nil }
        XCTAssertEqual(f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            XCTFail("Duplicate Quit must not open a second prompt")
            return false
        }, reply: { _ in XCTFail("Duplicate Quit must not receive a deferred reply") }), .cancel)
        prompt?.resume(returning: true)
        await Task.yield()
        XCTAssertTrue(replies.isEmpty)
        XCTAssertEqual(f.helperStops, 0)
        f.activity.end(token)
        await waitUntil { !replies.isEmpty }
        XCTAssertEqual(replies, [true])
        XCTAssertEqual(f.helperStops, 1)
        XCTAssertTrue(f.activity.isPreparingUpdate, "Keep gate shut until application exits")
        XCTAssertEqual(f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: { false }, reply: { _ in }), .now)
        f.coordinator.cancel()
    }

    func testOperationFinishingWhilePromptVisibleStillRequiresExplicitChoice() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        var prompt: CheckedContinuation<Bool, Never>?
        var replies: [Bool] = []
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            await withCheckedContinuation { prompt = $0 }
        }, reply: { replies.append($0) })
        await waitUntil { prompt != nil }
        f.activity.end(token)
        await Task.yield()
        XCTAssertTrue(replies.isEmpty)
        XCTAssertEqual(f.helperStops, 0)
        prompt?.resume(returning: false)
        await waitUntil { !replies.isEmpty }
        XCTAssertEqual(replies, [false])
        XCTAssertEqual(f.helperStops, 0)
    }

    func testAbortRejectsPendingQuitAndStaleChoiceCannotAffectNewManualInstall() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        var prompt: CheckedContinuation<Bool, Never>?
        var replies: [Bool] = []
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            await withCheckedContinuation { prompt = $0 }
        }, reply: { replies.append($0) })
        await waitUntil { prompt != nil }
        f.coordinator.cancel()
        XCTAssertEqual(replies, [false])
        XCTAssertEqual(f.promptsDismissed, 1)
        var installs = 0
        f.coordinator.requestInstallation { installs += 1 }
        await waitUntil { f.activity.isPreparingUpdate }
        prompt?.resume(returning: true)
        await Task.yield()
        XCTAssertEqual(replies, [false])
        XCTAssertTrue(f.coordinator.isPreparingInstallation)
        f.activity.end(token)
        await waitUntil { installs == 1 }
        XCTAssertEqual(f.helperStops, 1)
        XCTAssertEqual(installs, 1)
        f.coordinator.cancel()
    }

    func testHelperFailureRejectsQuitAndAllowsAnotherQuitAttempt() async {
        let f = Fixture()
        f.helperResult = false
        var replies: [Bool] = []
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: { true }, reply: { replies.append($0) })
        await waitUntil { !replies.isEmpty }
        XCTAssertEqual(replies, [false])
        XCTAssertEqual(f.failures, [true])
        XCTAssertFalse(f.activity.isPreparingUpdate)
        XCTAssertFalse(f.coordinator.isPreparingInstallation)
        f.helperResult = true
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: { true }, reply: { replies.append($0) })
        await waitUntil { replies.count == 2 }
        XCTAssertEqual(replies, [false, true])
        f.coordinator.cancel()
    }

    func testManualFailureRetainsInstallCallbackForRetryAndQuitCannotReplaceIt() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        f.helperResult = false
        var installs = 0
        f.coordinator.requestInstallation { installs += 1 }
        await waitUntil { f.activity.isPreparingUpdate }
        XCTAssertEqual(f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: { false }, reply: { _ in
            XCTFail("Quit cannot take ownership from a manual installation")
        }), .cancel)
        f.activity.end(token)
        await waitUntil { f.coordinator.canRetryInstallation }
        XCTAssertEqual(installs, 0)
        XCTAssertEqual(f.failures, [false])
        f.helperResult = true
        f.coordinator.retryInstallation()
        await waitUntil { installs == 1 }
        XCTAssertFalse(f.coordinator.canRetryInstallation)
        f.coordinator.cancel()
    }

    func testManualInstallJoiningPendingQuitRunsOnceAfterWorkFinishes() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        var prompt: CheckedContinuation<Bool, Never>?
        var events: [String] = []
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            await withCheckedContinuation { prompt = $0 }
        }, reply: { events.append("quit:\($0)") })
        await waitUntil { prompt != nil }
        f.coordinator.requestInstallation { events.append("install") }
        prompt?.resume(returning: true)
        await Task.yield()
        XCTAssertTrue(events.isEmpty)
        f.activity.end(token)
        await waitUntil { events.count == 2 }
        XCTAssertEqual(events, ["install", "quit:true"])
        XCTAssertEqual(f.helperStops, 1)
        f.coordinator.cancel()
    }

    func testStayRetainsJoiningManualHandlerForExplicitRetry() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        var prompt: CheckedContinuation<Bool, Never>?
        var replies: [Bool] = []
        var installs = 0
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            await withCheckedContinuation { prompt = $0 }
        }, reply: { replies.append($0) })
        await waitUntil { prompt != nil }
        f.coordinator.requestInstallation { installs += 1 }
        prompt?.resume(returning: false)
        await waitUntil { !replies.isEmpty }
        XCTAssertEqual(replies, [false])
        XCTAssertEqual(installs, 0)
        XCTAssertTrue(f.coordinator.canRetryInstallation)
        f.activity.end(token)
        f.coordinator.retryInstallation()
        await waitUntil { installs == 1 }
        XCTAssertEqual(f.helperStops, 1)
        f.coordinator.cancel()
    }

    func testCancellationReplyMaySynchronouslyStartANewPreparation() async throws {
        let f = Fixture()
        let token = try await f.activity.begin()
        var prompt: CheckedContinuation<Bool, Never>?
        var installs = 0
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            await withCheckedContinuation { prompt = $0 }
        }, reply: { ready in
            XCTAssertFalse(ready)
            XCTAssertFalse(f.coordinator.isPreparingInstallation)
            XCTAssertFalse(f.activity.isPreparingUpdate)
            f.coordinator.requestInstallation { installs += 1 }
        })
        await waitUntil { prompt != nil }
        f.coordinator.cancel()
        XCTAssertTrue(f.coordinator.isPreparingInstallation)
        await waitUntil { f.activity.isPreparingUpdate }
        prompt?.resume(returning: true)
        f.activity.end(token)
        await waitUntil { installs == 1 }
        XCTAssertEqual(f.helperStops, 1)
        f.coordinator.cancel()
    }

    func testUserCancelKeepsActiveWorkAndManualRetryWhileReleasingQueuedWork() async throws {
        let f = Fixture()
        let active = try await f.activity.begin()
        var installs = 0
        f.coordinator.requestInstallation { installs += 1 }
        await waitUntil { f.activity.isPreparingUpdate }
        let queued = Task { try await f.activity.begin() }
        await waitUntil { f.activity.queuedOperationCount == 1 }
        XCTAssertTrue(f.coordinator.canCancelPreparation)

        f.coordinator.cancel(preservingInstallHandler: true)

        XCTAssertFalse(f.coordinator.isPreparingInstallation)
        XCTAssertFalse(f.coordinator.canCancelPreparation)
        XCTAssertTrue(f.coordinator.canRetryInstallation)
        XCTAssertFalse(f.activity.isPreparingUpdate)
        XCTAssertTrue(f.activity.isBusy)
        XCTAssertEqual(f.helperStops, 0)
        XCTAssertEqual(installs, 0)
        let resumed = try await queued.value
        f.activity.end(resumed)
        XCTAssertTrue(f.activity.isBusy, "Cancel must not end the existing operation")

        f.coordinator.retryInstallation()
        await waitUntil { f.activity.isPreparingUpdate }
        XCTAssertEqual(installs, 0)
        f.activity.end(active)
        await waitUntil { installs == 1 }
        XCTAssertEqual(f.helperStops, 1)
        XCTAssertFalse(f.coordinator.canRetryInstallation)
        f.coordinator.cancel()
    }

    func testOrdinaryQuitAfterManualCancellationDoesNotReviveCancelledRelaunch() async throws {
        let f = Fixture()
        let active = try await f.activity.begin()
        var manualInstalls = 0
        f.coordinator.requestInstallation { manualInstalls += 1 }
        await waitUntil { f.activity.isPreparingUpdate }
        f.coordinator.cancel(preservingInstallHandler: true)
        XCTAssertTrue(f.coordinator.canRetryInstallation)

        var choices = 0
        var replies: [Bool] = []
        XCTAssertEqual(f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            choices += 1
            return true
        }, reply: { replies.append($0) }), .deferred)
        await waitUntil { choices == 1 }
        XCTAssertTrue(f.activity.isPreparingUpdate)
        XCTAssertEqual(f.helperStops, 0)
        f.activity.end(active)
        await waitUntil { replies.count == 1 }

        XCTAssertEqual(replies, [true])
        XCTAssertEqual(manualInstalls, 0, "Normal Quit must install on quit, without the cancelled manual relaunch")
        XCTAssertEqual(f.helperStops, 1)
        XCTAssertTrue(f.coordinator.readyToTerminate)
        f.coordinator.cancel()
    }

    func testUserCancelAfterChoosingWaitAllowsPreparedUpdateOnNextQuit() async throws {
        let f = Fixture()
        let active = try await f.activity.begin()
        var choices = 0
        var replies: [Bool] = []
        _ = f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            choices += 1
            return true
        }, reply: { replies.append($0) })
        await waitUntil { choices == 1 }

        f.coordinator.cancel(preservingInstallHandler: true)

        XCTAssertEqual(replies, [false])
        XCTAssertTrue(f.activity.isBusy)
        XCTAssertFalse(f.activity.isPreparingUpdate)
        XCTAssertFalse(f.coordinator.canRetryInstallation)
        XCTAssertEqual(f.helperStops, 0)

        XCTAssertEqual(f.coordinator.requestTermination(hasPreparedUpdate: true, chooseWait: {
            choices += 1
            return true
        }, reply: { replies.append($0) }), .deferred)
        await waitUntil { choices == 2 }
        f.activity.end(active)
        await waitUntil { replies.count == 2 }
        XCTAssertEqual(replies, [false, true])
        XCTAssertEqual(f.helperStops, 1)
        f.coordinator.cancel()
    }

    func testUserCancelDuringHelperWaitKeepsRetryAndIgnoresStaleHelperCompletion() async {
        let activity = AppOperationActivity()
        var helperWaits: [CheckedContinuation<Bool, Never>] = []
        var completedHelpers = 0
        var helperResumes = 0
        var installs = 0
        let coordinator = SelfUpdateInstallationCoordinator(
            activity: activity,
            stopHelper: {
                let ready = await withCheckedContinuation { helperWaits.append($0) }
                completedHelpers += 1
                return ready
            },
            resumeHelper: { helperResumes += 1 })
        coordinator.requestInstallation { installs += 1 }
        await waitUntil { helperWaits.count == 1 }

        coordinator.cancel(preservingInstallHandler: true)

        XCTAssertFalse(activity.isPreparingUpdate)
        XCTAssertEqual(helperResumes, 1)
        XCTAssertTrue(coordinator.canRetryInstallation)
        coordinator.retryInstallation()
        await waitUntil { helperWaits.count == 2 }
        helperWaits[0].resume(returning: true)
        await waitUntil { completedHelpers == 1 }
        XCTAssertEqual(installs, 0)
        XCTAssertTrue(coordinator.isPreparingInstallation)
        XCTAssertTrue(activity.isPreparingUpdate)
        helperWaits[1].resume(returning: true)
        await waitUntil { installs == 1 }
        XCTAssertEqual(completedHelpers, 2)
        XCTAssertEqual(installs, 1)
        coordinator.cancel()
    }

    func testUserCancelCannotReopenGateAfterHandoffButInstallerAbortCan() async {
        let f = Fixture()
        var installs = 0
        f.coordinator.requestInstallation { installs += 1 }
        await waitUntil { installs == 1 }
        XCTAssertTrue(f.coordinator.readyToTerminate)
        XCTAssertFalse(f.coordinator.canCancelPreparation)

        f.coordinator.cancel(preservingInstallHandler: true)

        XCTAssertTrue(f.coordinator.readyToTerminate)
        XCTAssertTrue(f.activity.isPreparingUpdate)
        XCTAssertFalse(f.coordinator.canRetryInstallation)
        XCTAssertEqual(f.helperResumes, 0)
        XCTAssertEqual(installs, 1)

        f.coordinator.cancel() // An actual installer error still resets state.
        XCTAssertFalse(f.coordinator.readyToTerminate)
        XCTAssertFalse(f.coordinator.isPreparingInstallation)
        XCTAssertFalse(f.activity.isPreparingUpdate)
        XCTAssertFalse(f.coordinator.canRetryInstallation)
        XCTAssertEqual(f.helperResumes, 1)
    }

    private func waitUntil(_ condition: @MainActor () -> Bool,
                           file: StaticString = #filePath, line: UInt = #line) async {
        let deadline = ContinuousClock.now + .seconds(2)
        while !condition(), ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(1))
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }
}
