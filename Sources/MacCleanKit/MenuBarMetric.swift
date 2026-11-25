import Foundation

/// The compact value shown next to the Mac Sai menu-bar icon, or none at all.
///
/// Raw values are persisted in the shared defaults suite, so they must remain
/// stable across releases.
public enum MenuBarMetric: String, CaseIterable, Identifiable, Sendable {
    case diskFree = "diskFree"
    case gpuUsage = "gpuUsage"
    case memoryUsage = "memoryUsage"
    case batteryTemperature = "temperature"
    case networkSpeed = "networkSpeed"
    case iconOnly = "iconOnly"

    public static let defaultsKey = "menuBarMetric"
    public static let fallback: MenuBarMetric = .diskFree

    public var id: String { rawValue }

    public static func resolve(_ rawValue: String?) -> Self {
        rawValue.flatMap(Self.init(rawValue:)) ?? fallback
    }

    public var localizedName: String {
        switch self {
        case .diskFree:
            L10n.tr("可用磁盘空间", "Free disk space")
        case .gpuUsage:
            L10n.tr("GPU 使用率", "GPU usage")
        case .memoryUsage:
            L10n.tr("内存使用率", "Memory usage")
        case .batteryTemperature:
            L10n.tr("电池温度", "Battery temperature")
        case .networkSpeed:
            L10n.tr("网络速度", "Network speed")
        case .iconOnly:
            L10n.tr("仅显示图标", "Icon only")
        }
    }

    /// Formats the selected value without silently substituting another metric.
    /// `nil` means the menu bar shows the icon alone.
    public func formattedValue(
        diskFree: UInt64,
        gpuUsage: Double?,
        memoryUsage: Double,
        batteryTemperature: Double?,
        downloadBytesPerSecond: Double? = nil,
        uploadBytesPerSecond: Double? = nil
    ) -> String? {
        switch self {
        case .diskFree:
            FileSizeFormatter.format(diskFree)
        case .gpuUsage:
            Self.formattedPercent(prefix: "GPU", value: gpuUsage)
        case .memoryUsage:
            Self.formattedPercent(prefix: "RAM", value: memoryUsage)
        case .batteryTemperature:
            Self.formattedTemperature(batteryTemperature)
        case .networkSpeed:
            "↓ \(Self.paddedRate(downloadBytesPerSecond)) ↑ \(Self.paddedRate(uploadBytesPerSecond))"
        case .iconOnly:
            nil
        }
    }

    /// Right-aligns a rate to the width of "99.9 MB/s". The label uses a
    /// monospaced font, so a fixed character count keeps the menu bar item
    /// from changing width, and shifting the icons beside it, on every update.
    private static func paddedRate(_ bytesPerSecond: Double?) -> String {
        let text = bytesPerSecond.map(NetworkRate.format) ?? "--"
        return String(repeating: " ", count: max(0, 9 - text.count)) + text
    }

    private static func formattedPercent(prefix: String, value: Double?) -> String {
        guard let value, value.isFinite else { return "\(prefix) --" }
        let percent = Int((min(max(value, 0), 1) * 100).rounded())
        return "\(prefix) \(percent)%"
    }

    private static func formattedTemperature(_ value: Double?) -> String {
        guard let value, value.isFinite, value > 0, value <= 120 else { return "--" }
        return "\(Int(value.rounded()))°C"
    }
}
