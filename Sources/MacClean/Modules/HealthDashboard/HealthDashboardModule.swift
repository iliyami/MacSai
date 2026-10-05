import Foundation
import MacCleanKit

public struct HealthDashboardModule: ScanModule {
    public let id = "health_dashboard"
    public var name: String { L10n.tr("系统健康", "Health Dashboard", "Состояние системы") }
    public let category = ModuleCategory.performance
    public let includedInSmartScan = false

    public init() {}

    public func scan() async -> [ScanResult] {
        return []
    }
}
