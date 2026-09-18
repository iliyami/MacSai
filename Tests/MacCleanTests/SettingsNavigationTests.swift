import XCTest
@testable import MacClean

final class SettingsNavigationTests: XCTestCase {
    func testSettingsDeepLinkRoundTrips() {
        XCTAssertEqual(SidebarItem.settings.deepLinkID, "settings")
        XCTAssertEqual(SidebarItem(deepLinkID: "settings"), .settings)
    }

    func testLaunchAtLoginRefreshesFromServiceStatusOnAppear() throws {
        let source = try settingsPageSource()

        XCTAssertTrue(
            source.contains("launchAtLogin = loginLauncher.refreshStatus()"),
            "Settings must replace stale AppStorage state with the live SMAppService status on appear"
        )
    }

    func testLaunchAtLoginRevertsToActualStatusAfterUpdate() throws {
        let source = try settingsPageSource()

        XCTAssertTrue(
            source.contains("launchAtLogin = await loginLauncher.setEnabled(requestedValue)"),
            "The toggle must reflect the actual SMAppService status after register/unregister"
        )
        XCTAssertFalse(
            source.contains(".onChange(of: launchAtLogin)"),
            "Programmatic status synchronization must not trigger another register/unregister operation"
        )
    }

    /// Settings is opened from the pinned footer, never from the scrolling
    /// section list. If it leaks into a section the sidebar shows it twice.
    func testSettingsExcludedFromSidebarSections() {
        let listed = SidebarSection.allCases.flatMap(\.items)
        XCTAssertFalse(listed.contains(.settings))
        XCTAssertTrue(SidebarItem.allCases.contains(.settings))
    }

    /// Existing module rows must be unaffected by the items filter.
    func testExistingSectionsStillListTheirItems() {
        XCTAssertEqual(SidebarSection.main.items, [.smartScan])
        XCTAssertTrue(SidebarSection.cleanup.items.contains(.systemJunk))
        XCTAssertTrue(SidebarSection.files.items.contains(.shredder))
    }

    private func settingsPageSource() throws -> String {
        let sourceURL = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Sources/MacClean/Views/Settings/SettingsPageView.swift")
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
