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
}
