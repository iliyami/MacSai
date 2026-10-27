import XCTest
@testable import MacCleanKit

final class SelfUpdateInstallationStateTests: XCTestCase {
    func testPreparedUpdateSurvivesDeclinedCheckAndNetworkFailure() {
        var state = SelfUpdateInstallationState()
        state.prepared()
        state.aborted(installationFailed: false) // Busy cleanup declines check.
        state.aborted(installationFailed: false) // Next check is offline.
        XCTAssertTrue(state.hasPreparedUpdate) // Normal Quit still stops helper.
    }

    func testSkipAndInstallerFailureClearThePreparedUpdate() {
        var state = SelfUpdateInstallationState()
        state.prepared()
        state.skipped()
        XCTAssertFalse(state.hasPreparedUpdate)
        state.prepared()
        state.aborted(installationFailed: true)
        XCTAssertFalse(state.hasPreparedUpdate)
    }
}
