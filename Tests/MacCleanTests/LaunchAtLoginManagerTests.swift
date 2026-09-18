import XCTest
import ServiceManagement
@testable import MacClean

@MainActor
final class LaunchAtLoginManagerTests: XCTestCase {
    func testRefreshStatusReadsCurrentServiceStatus() {
        let serviceStatus = StatusBox(.notRegistered)
        let manager = makeManager(statusProvider: { serviceStatus.value })

        XCTAssertFalse(manager.refreshStatus())
        XCTAssertEqual(manager.status, .notRegistered)

        serviceStatus.value = .enabled

        XCTAssertTrue(manager.refreshStatus())
        XCTAssertEqual(manager.status, .enabled)
    }

    func testFailedRegisterReturnsActualDisabledStatus() async {
        let manager = makeManager(
            statusProvider: { .notRegistered },
            registrationUpdater: { enabled in enabled ? "registration denied" : nil }
        )

        let actualValue = await manager.setEnabled(true)

        XCTAssertFalse(actualValue)
        XCTAssertEqual(manager.status, .notRegistered)
        XCTAssertNotNil(manager.lastError)
    }

    func testFailedUnregisterReturnsActualEnabledStatus() async {
        let manager = makeManager(
            statusProvider: { .enabled },
            registrationUpdater: { enabled in enabled ? nil : "unregister denied" }
        )

        let actualValue = await manager.setEnabled(false)

        XCTAssertTrue(actualValue)
        XCTAssertEqual(manager.status, .enabled)
        XCTAssertNotNil(manager.lastError)
    }

    private func makeManager(
        statusProvider: @escaping @MainActor () -> SMAppService.Status,
        registrationUpdater: @escaping @Sendable (Bool) -> String? = { _ in nil }
    ) -> LaunchAtLoginManager {
        LaunchAtLoginManager(
            statusProvider: statusProvider,
            registrationUpdater: registrationUpdater,
            minimumBusyDuration: .zero
        )
    }

    @MainActor
    private final class StatusBox {
        var value: SMAppService.Status

        init(_ value: SMAppService.Status) {
            self.value = value
        }
    }
}
