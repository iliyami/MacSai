import Foundation

/// Throughput between two samples of a cumulative byte counter.
public enum NetworkRate {
    /// Bytes per second from `previous` to `current` over `elapsed` seconds.
    /// Returns 0 when the counter went backwards: the per-interface `if_data`
    /// counters are 32-bit and wrap every 4 GiB, and the summed total drops
    /// when an interface (e.g. a VPN `utun`) goes away.
    public static func bytesPerSecond(current: UInt64, previous: UInt64, elapsed: TimeInterval) -> Double {
        guard elapsed > 0, current >= previous else { return 0 }
        return Double(current - previous) / elapsed
    }

    /// Human-readable rate, e.g. "12.5 MB/s". Shared by the popover and the
    /// menu-bar label so both read the same. "--" when unavailable.
    public static func format(_ bytesPerSecond: Double) -> String {
        guard bytesPerSecond.isFinite, bytesPerSecond >= 0 else { return "--" }
        if bytesPerSecond >= 1_000_000 {
            return String(format: "%.1f MB/s", bytesPerSecond / 1_000_000)
        } else if bytesPerSecond >= 1_000 {
            return String(format: "%.0f KB/s", bytesPerSecond / 1_000)
        } else {
            return String(format: "%.0f B/s", bytesPerSecond)
        }
    }
}
