import Foundation
import AppKit
import MacCleanKit

public struct SystemJunkModule: ScanModule {
    public let id = "system_junk"
    public var name: String { L10n.tr("系统垃圾", "System Junk", "Системный мусор") }
    public let category = ModuleCategory.cleanup

    private let scanner = TargetedScanner()

    public init() {}

    /// All categories the System Junk module runs. The pure target / filter
    /// declarations live in MacCleanKit and are tested there; this list is
    /// the only place the *full set* is composed.
    public static let allCategories: [JunkCategory] = [
        UserCacheCategory(),
        SystemCacheCategory(),
        UserLogCategory(),
        SystemLogCategory(),
        LanguageFilesCategory(),
        BrokenPreferencesCategory(),
        BrokenLoginItemsCategory(),
        DocumentVersionsCategory(),
        BrokenDownloadsCategory(),
        IOSDeviceBackupsCategory(),
        OldUpdatesCategory(),
        UniversalBinariesCategory(),
        XcodeJunkCategory(),
        DeletedUsersCategory(),
        UnusedDiskImagesCategory(),
        IncompleteDownloadsCategory(),
        AppLeftoversCategory(),
        PackageManagerCachesCategory(),
        IDECachesCategory(),
        AIToolCachesCategory(),
        ClipboardArchivesCategory(),
    ]

    public func scan() async -> [ScanResult] {
        await scanReportingPermissions().results
    }

    public func scanReportingPermissions(
        categories: [any JunkCategory] = Self.allCategories
    ) async -> (results: [ScanResult], permissionDeniedPaths: [URL]) {
        return await withTaskGroup(of: (result: ScanResult?, denied: [URL]).self) { group in
            for cat in categories {
                group.addTask {
                    // UniversalBinaries needs a system-side scanner (walks
                    // .app bundles, shells out to lipo, asks the policy)
                    // rather than the targeted path enumerator.
                    if cat.scanCategory == .universalBinaries {
                        let items = UniversalBinariesScanner.scanAllApplicationsDirectories()
                        guard !items.isEmpty else { return (nil, []) }
                        return (ScanResult(
                            category: .universalBinaries,
                            items: items,
                            autoSelect: cat.scanCategory.autoSelect
                        ), [])
                    }
                    // App leftovers: enumerates the safe Library subdirs for
                    // bundle-id-named entries whose owning app is uninstalled.
                    if cat.scanCategory == .appLeftovers {
                        let items = AppLeftoversScanner.scan()
                        guard !items.isEmpty else { return (nil, []) }
                        return (ScanResult(
                            category: .appLeftovers,
                            items: items,
                            autoSelect: cat.scanCategory.autoSelect
                        ), [])
                    }
                    // Deleted users: /Users folders that no longer match an
                    // active account per `dscl`. Its own scanner (not
                    // TargetedScanner) cross-checks against the live user
                    // list rather than a static path target.
                    if cat.scanCategory == .deletedUsers {
                        let items = DeletedUsersScanner.scanForDeletedUserFolders()
                        guard !items.isEmpty else { return (nil, []) }
                        return (ScanResult(
                            category: .deletedUsers,
                            items: items,
                            autoSelect: cat.scanCategory.autoSelect
                        ), [])
                    }
                    let outcome = await scanner.scanReportingPermissions(targets: cat.targets)
                    let items = outcome.items
                    var filtered = items

                    // Apply category-specific post-filter logic.
                    if let brokenPrefs = cat as? BrokenPreferencesCategory {
                        filtered = brokenPrefs.filterBroken(
                            items,
                            loadData: { try? Data(contentsOf: $0) },
                            appExistsForBundleID: {
                                NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) != nil
                            }
                        )
                    } else if let clipboardArchives = cat as? ClipboardArchivesCategory {
                        filtered = clipboardArchives.filterArchives(items)
                    } else if let packageManagers = cat as? PackageManagerCachesCategory {
                        filtered += PnpmStoreScanner.scan(roots: packageManagers.pnpmStoreRoots)
                    } else if let brokenLogin = cat as? BrokenLoginItemsCategory {
                        filtered = brokenLogin.filterBroken(
                            items,
                            loadData: { try? Data(contentsOf: $0) },
                            fileExists: { FileManager.default.fileExists(atPath: $0) },
                            appExistsForBundleID: {
                                NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) != nil
                            }
                        )
                    }

                    guard !filtered.isEmpty else { return (nil, outcome.permissionDeniedPaths) }
                    return (ScanResult(
                        category: cat.scanCategory,
                        items: filtered,
                        autoSelect: cat.scanCategory.autoSelect
                    ), outcome.permissionDeniedPaths)
                }
            }

            var results: [ScanResult] = []
            var deniedPaths: [URL] = []
            for await outcome in group {
                if let result = outcome.result {
                    results.append(result)
                }
                deniedPaths += outcome.denied
            }
            return (results.filteringUncleanable().sorted { $0.totalSize > $1.totalSize },
                    Array(Set(deniedPaths)).sorted { $0.path < $1.path })
        }
    }
}
