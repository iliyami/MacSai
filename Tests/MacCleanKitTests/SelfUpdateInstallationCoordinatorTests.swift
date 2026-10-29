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

    private func waitUntil(_ condition: @MainActor () -> Bool,
                           file: StaticString = #filePath, line: UInt = #line) async {
        let deadline = ContinuousClock.now + .seconds(2)
        while !condition(), ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(1))
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }
}
