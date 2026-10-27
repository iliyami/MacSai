import Foundation

/// Bulk selection must not silently opt into deleting personal data, emptying
/// Trash, or rewriting applications. Other categories stay available through
/// explicit selection, including the separate Select All action.
public enum CleanupSelectionPolicy {
    public static func safeURLs(in results: [ScanResult]) -> Set<URL> {
        Set(results.filter {
            $0.autoSelect && $0.category.autoSelect && $0.category.cleanupSafety != .reviewFirst
        }
            .flatMap { $0.items.map(\.url) })
    }

    public static func allURLs(in results: [ScanResult]) -> Set<URL> {
        Set(results.flatMap { $0.items.map(\.url) })
    }

    public static func selectedSize(_ selection: Set<URL>, sizesByURL: [URL: UInt64]) -> UInt64 {
        selection.reduce(0) { $0 + (sizesByURL[$1] ?? 0) }
    }

    public static func requiresReview(in results: [ScanResult], selection: Set<URL>) -> Bool {
        !selection.isSubset(of: safeURLs(in: results))
    }

    public static func selectedCategories(in results: [ScanResult], selection: Set<URL>) -> Set<ScanCategory> {
        Set(results.filter { $0.items.contains { selection.contains($0.url) } }.map(\.category))
    }

}
