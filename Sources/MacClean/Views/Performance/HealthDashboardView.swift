import SwiftUI
import MacCleanKit

struct HealthDashboardView: View {
    @State private var stats: SystemStatsCollector.SystemStats?
    private let collector = SystemStatsCollector()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.tr("系统健康", "Health Dashboard", "Состояние системы"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(L10n.tr("查看系统整体资源状态", "View overall system resource status", "Просмотр общего состояния ресурсов системы"))
                        .font(.system(size: 12))
                        .foregroundStyle(.primary.opacity(0.6))
                }
                Spacer()
            }
            .padding(20)
            
            ScrollView {
                VStack(spacing: 20) {
                    if let stats = stats {
                        // CPU & GPU
                        HStack(spacing: 16) {
                            statCard(title: "CPU", value: String(format: "%.1f%%", stats.cpuUsage * 100), icon: "cpu", color: .blue)
                            if let gpu = stats.gpuUsage {
                                statCard(title: "GPU", value: String(format: "%.1f%%", gpu * 100), icon: "memorychip", color: .purple)
                            }
                        }
                        
                        // Memory
                        let memPercent = Double(stats.memoryUsed) / Double(stats.memoryTotal) * 100
                        HStack(spacing: 16) {
                            statCard(title: L10n.tr("内存", "Memory", "Память"), value: String(format: "%.1f%%", memPercent), icon: "memorychip", color: .green)
                            statCard(title: L10n.tr("内存压力", "Memory Pressure", "Давление памяти"), value: String(format: "%.1f%%", stats.memoryPressure * 100), icon: "gauge.with.dots.needle.67percent", color: .orange)
                        }
                        
                        // Disk
                        let diskUsed = stats.diskTotal - stats.diskFree
                        let diskPercent = Double(diskUsed) / Double(stats.diskTotal) * 100
                        HStack(spacing: 16) {
                            statCard(title: L10n.tr("磁盘使用率", "Disk Usage", "Использование диска"), value: String(format: "%.1f%%", diskPercent), icon: "internaldrive", color: .mint)
                        }
                        
                        // Battery
                        if let bat = stats.batteryLevel {
                            HStack(spacing: 16) {
                                statCard(title: L10n.tr("电池电量", "Battery Level", "Уровень заряда"), value: String(format: "%.0f%%", bat * 100), icon: "battery.100", color: .green)
                                if let health = stats.batteryHealth {
                                    statCard(title: L10n.tr("电池健康度", "Battery Health", "Здоровье батареи"), value: String(format: "%.0f%%", health * 100), icon: "heart", color: .red)
                                }
                                if let cycles = stats.batteryCycleCount {
                                    statCard(title: L10n.tr("循环次数", "Cycle Count", "Количество циклов"), value: "\(cycles)", icon: "arrow.triangle.2.circlepath", color: .gray)
                                }
                            }
                        }
                    } else {
                        ProgressView()
                            .padding(.top, 50)
                    }
                }
                .padding(20)
            }
        }
        .task {
            while !Task.isCancelled {
                stats = await collector.collect()
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(size: 24, weight: .semibold))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
