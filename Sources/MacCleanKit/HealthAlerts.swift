import Foundation

/// User choices for the menu bar widget's health alerts. Stored in the
/// shared suite: Settings writes them in the main app and the widget's
/// `HealthMonitor` reads them on every tick.
public enum HealthAlertSettings {
    public static let memoryPressureAlertKey = "memoryPressureAlertEnabled"
    public static let swapAlertThresholdKey = "swapAlertThresholdGB"

    /// Offered swap thresholds in GB; 0 means the alert is off. Decimal GB
    /// so the size reads "4 GB" through `FileSizeFormatter`, like the swap
    /// figure the widget shows.
    public static let swapThresholdChoices = [0, 2, 4, 8]

    public static func bytes(forGB gigabytes: Int) -> UInt64 {
        UInt64(max(gigabytes, 0)) * 1_000_000_000
    }

    /// On by default, as it was before the setting existed.
    public static var memoryPressureAlertEnabled: Bool {
        SharedAppState.defaults.object(forKey: memoryPressureAlertKey) as? Bool ?? true
    }

    /// nil when the swap alert is off (the default).
    public static var swapAlertThreshold: UInt64? {
        let gigabytes = SharedAppState.defaults.integer(forKey: swapAlertThresholdKey)
        return gigabytes > 0 ? bytes(forGB: gigabytes) : nil
    }
}

/// Decides when a swap alert fires: once when swap crosses the threshold,
/// then not again until swap has fallen well below it. macOS releases swap
/// slowly, so without that gap the alert would repeat every time usage
/// wobbles around the line.
public struct SwapAlertLatch: Codable, Equatable, Sendable {
    /// Swap must drop under this fraction of the threshold to re-arm.
    public static let rearmFraction = 0.75

    /// The threshold the alert last fired at; nil while armed.
    public private(set) var firedAtThreshold: UInt64?

    public init(firedAtThreshold: UInt64? = nil) {
        self.firedAtThreshold = firedAtThreshold
    }

    /// Feeds one swap sample and returns whether to notify now. A changed
    /// threshold re-arms, so lowering it below current usage alerts once.
    public mutating func shouldAlert(swapUsed: UInt64, threshold: UInt64?) -> Bool {
        guard let threshold, threshold > 0 else {
            firedAtThreshold = nil
            return false
        }
        if let fired = firedAtThreshold {
            if fired == threshold {
                if Double(swapUsed) < Double(threshold) * Self.rearmFraction {
                    firedAtThreshold = nil
                }
                return false
            }
            firedAtThreshold = nil
        }
        guard swapUsed >= threshold else { return false }
        firedAtThreshold = threshold
        return true
    }
}

/// Copy for the alert settings, the widget's swap line and the swap
/// notification. Whole sentences with placeholders, so every language
/// can match its translation key.
public enum HealthAlertStrings {
    public static var sectionTitle: String {
        L10n.tr("提醒", "Alerts", "Уведомления")
    }

    public static var memoryPressureToggle: String {
        L10n.tr("内存压力提醒", "Memory pressure alert", "Уведомление о нагрузке на память")
    }

    public static var memoryPressureCaption: String {
        L10n.tr("内存压力持续偏高时通知你。", "Notifies you when memory pressure stays high.", "Сообщает, когда нагрузка на память долго остаётся высокой.")
    }

    public static var swapPicker: String {
        L10n.tr("交换空间提醒", "Swap usage alert", "Уведомление о файле подкачки")
    }

    public static var swapCaption: String {
        L10n.tr(
            "交换空间超过所选大小时通知一次，降到明显低于该值后才会再次提醒。",
            "Notifies you once when swap goes above the chosen size, and again only after it has dropped well below it.",
            "Сообщает один раз, когда подкачка превышает выбранный объём, и снова только после того, как она заметно уменьшится."
        )
    }

    public static var swapOff: String {
        L10n.tr("不提醒", "Off", "Выкл.")
    }

    public static var widgetRequired: String {
        L10n.tr(
            "提醒由菜单栏小组件发送，需要保持开启。",
            "Alerts are sent by the menu bar widget, so it needs to be on.",
            "Уведомления отправляет виджет в строке меню, поэтому он должен быть включён."
        )
    }

    public static func swapLine(_ used: UInt64) -> String {
        L10n.tr("交换空间 {size}", "Swap {size}", "Подкачка {size}")
            .replacingOccurrences(of: "{size}", with: FileSizeFormatter.format(used))
    }

    public static var swapAlertTitle: String {
        L10n.tr("交换空间使用过高", "Swap usage high", "Подкачка слишком велика")
    }

    public static func swapAlertBody(used: UInt64, threshold: UInt64) -> String {
        L10n.tr(
            "你的 Mac 正在使用 {used} 交换空间，超过了你设置的 {limit} 提醒值。退出不用的应用可以减轻内存压力。",
            "Your Mac is using {used} of swap, above your {limit} alert. Quitting apps you aren't using eases memory pressure.",
            "Mac использует {used} подкачки, больше заданного порога {limit}. Закройте неиспользуемые приложения, чтобы снизить нагрузку на память."
        )
        .replacingOccurrences(of: "{used}", with: FileSizeFormatter.format(used))
        .replacingOccurrences(of: "{limit}", with: FileSizeFormatter.format(threshold))
    }
}
