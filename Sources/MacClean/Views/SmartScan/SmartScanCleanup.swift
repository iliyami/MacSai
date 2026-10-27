import Foundation
import MacCleanKit

/// Pure helpers turning Smart Scan's per-module results into the inputs
/// `CleanActions.executeUserClean` expects. SwiftUI-free for testing.
enum SmartScanCleanup {
    /// One module's contribution to the post-clean "Recently cleaned" list (#4).
    struct RecentlyCleanedRow: Equatable, Sendable {
        let moduleID: String
        let moduleName: String
        let itemCount: Int
        let size: UInt64
    }

    static func allResults(from modules: [ModuleScanResult]) -> [ScanResult] {
        modules.flatMap(\.categories).filter { !$0.items.isEmpty }
    }

    /// Start with categories approved for automatic cleanup; personal data and
    /// irreversible actions still need an explicit selection.
    static func defaultSelection(from modules: [ModuleScanResult]) -> Set<URL> {
        CleanupSelectionPolicy.safeURLs(in: allResults(from: modules))
    }

    /// Per-module size/count of the user's selection, in module scan order.
    /// URLs that appear in more than one category inside a module are counted once.
    static func recentlyCleanedBreakdown(
        from modules: [ModuleScanResult],
        selectedItems: Set<URL>
    ) -> [RecentlyCleanedRow] {
        guard !selectedItems.isEmpty else { return [] }
        return modules.compactMap { module in
            var seen = Set<URL>()
            var count = 0
            var size: UInt64 = 0
            for result in module.categories {
                for item in result.items where selectedItems.contains(item.url) {
                    guard seen.insert(item.url).inserted else { continue }
                    count += 1
                    size += item.size
                }
            }
            guard count > 0 else { return nil }
            return RecentlyCleanedRow(
                moduleID: module.moduleID,
                moduleName: module.moduleName,
                itemCount: count,
                size: size
            )
        }
    }
}
