import Foundation

/// Initial selection preserves the scanner's opt-in contract. Global buttons
/// also respect opt-outs; review-only results remain manually selectable.
public enum CleanupSelectionPolicy {
    public static func initialURLs(in results: [ScanResult]) -> Set<URL> {
        Set(results.filter { $0.autoSelect && $0.category.autoSelect }
            .flatMap { $0.items.map(\.url) })
    }

    public static func safeURLs(in results: [ScanResult]) -> Set<URL> {
        let reviewURLs = Set(results.filter { $0.category.cleanupSafety == .reviewFirst }
            .flatMap { $0.items.map(\.url) })
        return allURLs(in: results).subtracting(reviewURLs)
    }

    /// "All" means every result eligible for automatic selection, including
    /// collapsed categories. Possible Threats includes community-reported
    /// MalwareBazaar matches and must never be added by a global button.
    public static func allURLs(in results: [ScanResult]) -> Set<URL> {
        let reviewOnlyURLs = Set(results.filter {
            !$0.autoSelect || !$0.category.autoSelect || $0.category == .possibleThreats
        }.flatMap { $0.items.map(\.url) })
        // A URL listed in both an eligible and a review-only result stays out.
        return initialURLs(in: results).subtracting(reviewOnlyURLs)
    }

    /// An explicit checkbox on a named category may select review-only items.
    public static func togglingCategory(
        _ category: ScanCategory, in results: [ScanResult], selection: Set<URL>
    ) -> Set<URL> {
        let urls = Set(results.filter { $0.category == category }.flatMap { $0.items.map(\.url) })
        return urls.isSubset(of: selection) ? selection.subtracting(urls) : selection.union(urls)
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
