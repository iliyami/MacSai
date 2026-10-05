import SwiftUI
import MacCleanKit

struct NetworkHogsView: View {
    @State private var isLoading = true
    @State private var hasPermission = false

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "network")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text(L10n.tr("网络监控器正在开发中...", "Network monitor is under development...", "Сетевой монитор в разработке..."))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Text(L10n.tr("需要完全磁盘访问权限和系统扩展才能捕获进程级流量。", "Requires Full Disk Access and system extensions to capture per-process traffic.", "Требуется полный доступ к диску и системные расширения для захвата трафика процессов."))
                .font(.system(size: 11))
                .foregroundStyle(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
