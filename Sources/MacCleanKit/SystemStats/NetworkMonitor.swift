import Foundation
import SystemConfiguration

public actor NetworkSpeedMonitor {
    public struct NetworkSpeed: Sendable {
        public let bytesIn: UInt64
        public let bytesOut: UInt64
        public let bytesInPerSecond: Double
        public let bytesOutPerSecond: Double

        public var formattedIn: String { formatSpeed(bytesInPerSecond) }
        public var formattedOut: String { formatSpeed(bytesOutPerSecond) }

        private func formatSpeed(_ bps: Double) -> String {
            if bps >= 1_000_000 {
                return String(format: "%.1f MB/s", bps / 1_000_000)
            } else if bps >= 1_000 {
                return String(format: "%.0f KB/s", bps / 1_000)
            } else {
                return String(format: "%.0f B/s", bps)
            }
        }
    }

    private var previousBytesIn: UInt64 = 0
    private var previousBytesOut: UInt64 = 0
    private var previousTimestamp: Date?

    public init() {}

    public func measure() -> NetworkSpeed {
        let (totalIn, totalOut) = getNetworkBytes()
        let now = Date()

        var inPerSec: Double = 0
        var outPerSec: Double = 0

        if let prevTime = previousTimestamp {
            let elapsed = now.timeIntervalSince(prevTime)
            if elapsed > 0 {
                inPerSec = Double(totalIn - previousBytesIn) / elapsed
                outPerSec = Double(totalOut - previousBytesOut) / elapsed
                // Clamp negative values (counter wrap)
                inPerSec = max(0, inPerSec)
                outPerSec = max(0, outPerSec)
            }
        }

        previousBytesIn = totalIn
        previousBytesOut = totalOut
        previousTimestamp = now

        return NetworkSpeed(
            bytesIn: totalIn,
            bytesOut: totalOut,
            bytesInPerSecond: inPerSec,
            bytesOutPerSecond: outPerSec
        )
    }

    private nonisolated func getNetworkBytes() -> (UInt64, UInt64) {
        var ifaddrs: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrs) == 0, let firstAddr = ifaddrs else { return (0, 0) }
        defer { freeifaddrs(ifaddrs) }

        var totalIn: UInt64 = 0
        var totalOut: UInt64 = 0

        var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = cursor {
            // Advance first so every `continue` below is safe (no infinite loop).
            defer { cursor = addr.pointee.ifa_next }

            let name = String(cString: addr.pointee.ifa_name)

            // Only count physical interfaces (en0, en1, etc.)
            guard name.hasPrefix("en") || name.hasPrefix("utun") || name.hasPrefix("pdp_ip") else { continue }

            // ifa_addr can legitimately be NULL for some interfaces; the old
            // unconditional `.pointee` deref crashed the whole helper on those
            // (issue #78). Guard before touching it.
            guard let ifaAddr = addr.pointee.ifa_addr else { continue }
            guard ifaAddr.pointee.sa_family == UInt8(AF_LINK) else { continue }
            guard let data = addr.pointee.ifa_data else { continue }

            let networkData = data.assumingMemoryBound(to: if_data.self)
            totalIn += UInt64(networkData.pointee.ifi_ibytes)
            totalOut += UInt64(networkData.pointee.ifi_obytes)
        }

        return (totalIn, totalOut)
    }
}
