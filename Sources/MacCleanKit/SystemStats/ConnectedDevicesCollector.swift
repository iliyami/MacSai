import Foundation
import AppKit

public struct ConnectedDevices: Sendable, Equatable {
    public let externalVolumes: [ExternalVolume]
    public let externalDisplays: Int

    public struct ExternalVolume: Sendable, Equatable, Identifiable {
        public let id: String
        public let name: String
        public let totalBytes: UInt64
        public let freeBytes: UInt64
    }

    public init(externalVolumes: [ExternalVolume], externalDisplays: Int) {
        self.externalVolumes = externalVolumes
        self.externalDisplays = externalDisplays
    }

    public var hasAny: Bool {
        !externalVolumes.isEmpty || externalDisplays > 0
    }
}

public actor ConnectedDevicesCollector {
    public init() {}

    public func collect() async -> ConnectedDevices {
        let volumes = enumerateExternalVolumes()
        // `NSScreen.screens` includes the built-in display, so external
        // count = total - 1. Read on @MainActor since NSScreen is main-
        // only; the value is small and the hop is cheap.
        let displays = await MainActor.run { max(0, NSScreen.screens.count - 1) }
        return ConnectedDevices(externalVolumes: volumes, externalDisplays: displays)
    }

    private func enumerateExternalVolumes() -> [ConnectedDevices.ExternalVolume] {
        let keys: [URLResourceKey] = [
            .volumeIsRemovableKey,
            .volumeIsInternalKey,
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey,
        ]
        let resourceKeySet = Set(keys)
        guard let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: keys,
            options: [.skipHiddenVolumes]
        ) else { return [] }

        return urls.compactMap { url -> ConnectedDevices.ExternalVolume? in
            guard let values = try? url.resourceValues(forKeys: resourceKeySet) else {
                return nil
            }
            // "External" = removable (USB stick) OR not-internal
            // (network-mounted, externally-attached). The default
            // root volume is internal & non-removable, so we drop it.
            let isRemovable = values.volumeIsRemovable ?? false
            let isInternal = values.volumeIsInternal ?? true
            guard isRemovable || !isInternal else { return nil }

            let name = values.volumeName ?? url.lastPathComponent
            let total = UInt64(values.volumeTotalCapacity ?? 0)
            let free = UInt64(values.volumeAvailableCapacity ?? 0)
            return ConnectedDevices.ExternalVolume(
                id: url.path,
                name: name,
                totalBytes: total,
                freeBytes: free
            )
        }
    }
}
