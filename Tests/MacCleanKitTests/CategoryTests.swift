import XCTest
import Foundation
@testable import MacCleanKit

/// Tests for the 16 System Junk categories (the pure data declarations live
/// in MacCleanKit/Categories/).
final class CategoryTests: XCTestCase {

    // MARK: - Each category has at least one target

    func testEveryCategoryHasAScanCategory() {
        let allCategories: [JunkCategory] = [
            UserCacheCategory(), SystemCacheCategory(), UserLogCategory(), SystemLogCategory(),
            LanguageFilesCategory(), BrokenPreferencesCategory(), BrokenLoginItemsCategory(),
            DocumentVersionsCategory(), BrokenDownloadsCategory(), IOSDeviceBackupsCategory(),
            OldUpdatesCategory(), UniversalBinariesCategory(), XcodeJunkCategory(),
            DeletedUsersCategory(), UnusedDiskImagesCategory(), IncompleteDownloadsCategory(),
        ]
        // 16 categories
        XCTAssertEqual(allCategories.count, 16)
        // Distinct ScanCategory values
        let scanCategories = Set(allCategories.map { $0.scanCategory })
        XCTAssertEqual(scanCategories.count, allCategories.count, "All categories must have distinct ScanCategory values")
    }

    // MARK: - UserCacheCategory

    func testUserCacheTargetsUserCachesDir() {
        let cat = UserCacheCategory()
        XCTAssertEqual(cat.targets.count, 1)
        XCTAssertEqual(cat.targets[0].path, MCConstants.userCaches)
        XCTAssertTrue(cat.targets[0].recursive)
    }

    func testUserCacheExcludesSpotify() {
        let cat = UserCacheCategory()
        let patterns = cat.targets[0].excludePatterns
        XCTAssertTrue(patterns.contains("com.spotify.client"))
    }

    func testUserCacheLeavesPackageManagerCachesToTheirOwnCategory() {
        // Homebrew and pip live under ~/Library/Caches but belong to the
        // opt-in Package Manager Caches card. Listing them in the
        // auto-selected User Caches too would bypass that opt-in and count
        // their size twice.
        let userCaches = UserCacheCategory().targets[0]
        let packageManagerPaths = Set(PackageManagerCachesCategory().targets.map(\.path))
        for path in [MCConstants.homebrewCache, MCConstants.pipCache] {
            XCTAssertTrue(packageManagerPaths.contains(path))
            XCTAssertTrue(userCaches.isExcludedPath(path), "\(path.path) must be skipped by User Caches")
            XCTAssertTrue(userCaches.isExcludedPath(path.appending(path: "downloads/x.tar.gz")))
        }
        XCTAssertFalse(userCaches.isExcludedPath(MCConstants.userCaches.appending(path: "com.example.app")))
        XCTAssertFalse(userCaches.isExcludedPath(MCConstants.userCaches.appending(path: "pipeline-tool")))
    }

    // MARK: - SystemCacheCategory

    func testSystemCacheTargetsSystemCaches() {
        let cat = SystemCacheCategory()
        XCTAssertEqual(cat.targets[0].path, MCConstants.systemCaches)
    }

    // MARK: - Log categories

    func testUserLogTargetsLogExtensions() {
        let cat = UserLogCategory()
        let exts = cat.targets[0].fileExtensions
        XCTAssertTrue(exts?.contains("log") == true)
        XCTAssertTrue(exts?.contains("crash") == true)
    }

    func testUserLogsIncludeOpenClawLogsOnly() {
        let targets = UserLogCategory().targets
        XCTAssertTrue(targets.contains { $0.path == MCConstants.openClawLogs && $0.recursive })

        guard let home = targets.first(where: { $0.path == MCConstants.openClawHome }) else {
            return XCTFail("~/.openclaw must be scanned for stray log files")
        }
        // Only log files outside logs/: never config, credentials or workspace data.
        XCTAssertEqual(home.fileExtensions, ["log"])
        XCTAssertFalse(home.matchesByNameRules(MCConstants.openClawHome.appending(path: "openclaw.json")))
        XCTAssertTrue(home.matchesByNameRules(MCConstants.openClawHome.appending(path: "agents/main/run.log")))
        // logs/ belongs to its own target, so nothing is listed twice.
        XCTAssertTrue(home.isExcludedPath(MCConstants.openClawLogs.appending(path: "gateway.log")))
        XCTAssertTrue(home.isExcludedPath(MCConstants.openClawWorkspace.appending(path: "notes/build.log")))
    }

    func testUserLogsPreserveCleanupDiagnosticsWithoutExcludingOtherApps() {
        let target = UserLogCategory().targets[0]
        XCTAssertTrue(target.isExcludedPath(MCConstants.operationLogDir))
        XCTAssertTrue(target.isExcludedPath(MCConstants.operationLogFile))
        XCTAssertTrue(target.isExcludedPath(MCConstants.cleanHistoryFile))
        XCTAssertTrue(target.isExcludedPath(
            MCConstants.operationLogDir.appending(path: "archive/previous.log")
        ))

        let unrelatedLog = MCConstants.userLogs.appending(path: "ExampleApp/session.log")
        XCTAssertFalse(target.isExcludedPath(unrelatedLog))
        XCTAssertTrue(target.matchesByNameRules(unrelatedLog))
        // Match a complete directory component, not a name prefix.
        XCTAssertFalse(target.isExcludedPath(
            MCConstants.userLogs.appending(path: "MacClean-other/operations.log")
        ))
    }

    func testSystemLogTargetsTwoDirs() {
        let cat = SystemLogCategory()
        XCTAssertEqual(cat.targets.count, 2)
        let paths = cat.targets.map(\.path)
        XCTAssertTrue(paths.contains(MCConstants.systemLogs))
        XCTAssertTrue(paths.contains(MCConstants.varLog))
    }

    // MARK: - Language files

    func testLanguageFilesPreservesEnglish() {
        let cat = LanguageFilesCategory()
        let excludes = cat.targets[0].excludePatterns
        XCTAssertTrue(excludes.contains("en.lproj"))
        XCTAssertTrue(excludes.contains("Base.lproj"))
    }

    // MARK: - Document versions

    func testDocumentVersionsMinAge() {
        let cat = DocumentVersionsCategory()
        XCTAssertEqual(cat.targets[0].minAge, 14400) // 4 hours
    }

    // MARK: - Broken downloads

    func testBrokenDownloadsExtensions() {
        let cat = BrokenDownloadsCategory()
        let exts = cat.targets[0].fileExtensions
        XCTAssertEqual(exts, ["download", "crdownload", "part", "partial"])
    }

    // MARK: - iOS device backups

    func testIOSBackupsMinAge() {
        let cat = IOSDeviceBackupsCategory()
        XCTAssertEqual(cat.targets[0].minAge, 30 * 24 * 3600)
    }

    // MARK: - Old updates

    func testOldUpdatesPkgOnly() {
        let cat = OldUpdatesCategory()
        let exts = cat.targets[0].fileExtensions
        XCTAssertEqual(exts, ["pkg", "mpkg"])
    }

    // MARK: - Unused disk images

    func testUnusedDiskImagesExtensions() {
        let cat = UnusedDiskImagesCategory()
        let exts = cat.targets[0].fileExtensions
        XCTAssertEqual(exts, ["dmg", "iso", "sparseimage"])
        XCTAssertEqual(cat.targets[0].minAge, 7 * 24 * 3600)
    }

    // MARK: - Xcode junk

    func testXcodeJunkTargetsDerivedDataAndArchives() {
        let cat = XcodeJunkCategory()
        let paths = cat.targets.map(\.path)
        XCTAssertTrue(paths.contains(MCConstants.xcodeDerivedData))
        XCTAssertTrue(paths.contains(MCConstants.xcodeArchives))
        XCTAssertTrue(paths.contains(MCConstants.coreSimulator))
    }

    // MARK: - Incomplete downloads

    func testIncompleteDownloadsTwoTargets() {
        let cat = IncompleteDownloadsCategory()
        XCTAssertEqual(cat.targets.count, 2)
        XCTAssertEqual(cat.targets[0].path, MCConstants.downloads)
        XCTAssertTrue(cat.targets[1].path.path(percentEncoded: false).hasPrefix("/var/folders/")
                      || cat.targets[1].path.path(percentEncoded: false).hasPrefix("/tmp"),
                      "Second target should be temporary directory")
    }
}
