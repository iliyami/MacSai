import SwiftUI
import MacCleanKit

/// One explanation of cleanup permissions, shared by setup and cleanup
/// screens. macOS does not expose a universal "grant all" or FDA status API.
struct CleanupPermissionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Label(L10n.tr("清理权限", "Cleanup permissions", "Разрешения для очистки"), systemImage: "lock.shield")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.tr("完全磁盘访问权限", "Full Disk Access", "Полный доступ к диску"))
                        .font(.headline)
                    Text(L10n.tr(
                        "允许 Mac Sai 扫描邮件、浏览器数据和其他受保护的文件夹。在系统设置中添加 Mac Sai 并开启权限，然后重新启动应用并重新扫描。",
                        "Lets Mac Sai scan Mail, browser data and other protected folders. Add Mac Sai and enable it in System Settings, then restart the app and scan again.",
                        "Позволяет Mac Sai сканировать Почту, данные браузеров и другие защищённые папки. Добавьте Mac Sai и включите доступ в Системных настройках, затем перезапустите приложение и повторите сканирование."))
                    Button(L10n.tr("打开完全磁盘访问设置", "Open Full Disk Access Settings", "Открыть настройки доступа к диску")) {
                        PermissionManager.shared.openFullDiskAccessSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.tr("管理员确认", "Administrator approval", "Подтверждение администратора"))
                        .font(.headline)
                    Text(L10n.tr(
                        "移动受保护的项目时，macOS 可能仍会要求密码或触控 ID。完全磁盘访问权限不能代替管理员确认。Mac Sai 不保存您的密码，也不能提前批准所有操作。",
                        "macOS may still ask for a password or Touch ID when moving protected items. Full Disk Access does not replace administrator approval. Mac Sai does not save your password and cannot approve every operation in advance.",
                        "При перемещении защищённых объектов macOS может запросить пароль или Touch ID. Полный доступ к диску не заменяет подтверждение администратора. Mac Sai не хранит пароль и не может заранее разрешить все операции."))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.tr("批量移到废纸篓", "Move to Trash in batches", "Перемещение в Корзину группами"))
                        .font(.headline)
                    Text(L10n.tr(
                        "清理会将选中的项目分组交给 macOS，减少逐项请求。系统决定是否需要再次确认。取消后，当前组会先完成；已移动的项目仍会显示在清理历史中。",
                        "Cleanup sends selected items to macOS in groups to reduce individual requests. The system decides when further approval is needed. Cancelling finishes the current group first; items already moved remain in cleanup history.",
                        "Очистка передаёт выбранные объекты в macOS группами, чтобы сократить отдельные запросы. Необходимость повторного подтверждения определяет система. При отмене текущая группа сначала завершается; уже перемещённые объекты остаются в истории очистки."))
                }
            }
            .font(.callout)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 480, alignment: .leading)
            .padding(24)
        }
    }
}

struct CleanupPermissionsButton: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label(L10n.tr("权限", "Permissions", "Разрешения"), systemImage: "lock.shield")
        }
        .sheet(isPresented: $isPresented) {
            VStack(spacing: 0) {
                CleanupPermissionsView()
                HStack {
                    Spacer()
                    Button(L10n.tr("完成", "Done", "Готово")) { isPresented = false }
                        .keyboardShortcut(.defaultAction)
                }
                .padding()
            }
            .frame(width: 560, height: 560)
        }
    }
}
