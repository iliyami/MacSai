import Foundation

/// Snapshot of a running app for the Optimization → Resource Hogs list.
/// Pure data — collected by `ProcessStatsCollector`, ranked here.
public struct ResourceHogSnapshot: Equatable, Sendable {
    public let pid: Int32
    public let name: String
    public let cpuPercent: Double
    public let memoryBytes: UInt64
    public let bundleIdentifier: String?

    public init(
        pid: Int32,
        name: String,
        cpuPercent: Double,
        memoryBytes: UInt64,
        bundleIdentifier: String?
    ) {
        self.pid = pid
        self.name = name
        self.cpuPercent = cpuPercent
        self.memoryBytes = memoryBytes
        self.bundleIdentifier = bundleIdentifier
    }
}

/// A ranked row ready for the Resource Hogs UI, including whether Quit is
/// allowed (never for Mac Sai itself or essential shell processes).
public struct ResourceHogRow: Equatable, Sendable, Identifiable {
    public var id: Int32 { snapshot.pid }
    public let snapshot: ResourceHogSnapshot
    public let canQuit: Bool

    public init(snapshot: ResourceHogSnapshot, canQuit: Bool) {
        self.snapshot = snapshot
        self.canQuit = canQuit
    }
}

/// Pure ranking / quit-safety for Resource Hogs (issue #51).
public enum ResourceHogsPolicy {
    public enum SortKey: String, Sendable, CaseIterable {
        case cpu
        case memory
    }

    /// Bundle IDs we never offer a Quit button for. Quitting Finder/Dock
    /// bricks the desktop session; quitting ourselves mid-clean is nonsense.
    public static let neverQuitBundleIDs: Set<String> = [
        MCConstants.bundleIdentifier,
        MCConstants.helperBundleIdentifier,
        MCConstants.menuBundleIdentifier,
        "com.apple.finder",
        "com.apple.dock",
        "com.apple.loginwindow",
        "com.apple.WindowServer",
        "com.apple.systemuiserver",
    ]

    public static func canQuit(bundleIdentifier: String?) -> Bool {
        guard let id = bundleIdentifier, !id.isEmpty else { return true }
        return !neverQuitBundleIDs.contains(id)
    }

    public static func ranked(
        _ snapshots: [ResourceHogSnapshot],
        sortBy: SortKey,
        limit: Int
    ) -> [ResourceHogSnapshot] {
        let sorted: [ResourceHogSnapshot]
        switch sortBy {
        case .cpu:
            sorted = snapshots.sorted { $0.cpuPercent > $1.cpuPercent }
        case .memory:
            sorted = snapshots.sorted { $0.memoryBytes > $1.memoryBytes }
        }
        guard limit >= 0 else { return sorted }
        return Array(sorted.prefix(limit))
    }

    public static func rows(
        from snapshots: [ResourceHogSnapshot],
        sortBy: SortKey,
        limit: Int
    ) -> [ResourceHogRow] {
        ranked(snapshots, sortBy: sortBy, limit: limit).map { snap in
            ResourceHogRow(snapshot: snap, canQuit: canQuit(bundleIdentifier: snap.bundleIdentifier))
        }
    }
}
