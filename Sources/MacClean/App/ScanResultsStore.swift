import Foundation
import MacCleanKit

/// Caches each module's last scan so navigating away and back doesn't lose
/// it (#21.3). Keyed by SidebarItem. Module views read/write this instead of
/// relying solely on local @State, which is discarded when ContentView
/// recreates the view on selection change.
@Observable
public final class ScanResultsStore {
    public struct Entry {
        public var results: [ScanResult]
        public var selection: Set<URL>
        public var scanComplete: Bool
        public init(results: [ScanResult], selection: Set<URL>, scanComplete: Bool) {
            self.results = results
            self.selection = selection
            self.scanComplete = scanComplete
        }
    }

    private var entries: [SidebarItem: Entry] = [:]
    /// Why each Malware Removal item was flagged, kept alongside its entry so
    /// the reasons survive switching to another module and back.
    public var malwareReport: MalwareScanReport?
    public init() {}

    public func entry(for item: SidebarItem) -> Entry? { entries[item] }

    public func save(results: [ScanResult], selection: Set<URL>, scanComplete: Bool, for item: SidebarItem) {
        entries[item] = Entry(results: results, selection: selection, scanComplete: scanComplete)
    }

    public func clear(_ item: SidebarItem) {
        entries[item] = nil
        if item == .malwareRemoval { malwareReport = nil }
    }
    public func clearAll() {
        entries.removeAll()
        malwareReport = nil
    }
}
