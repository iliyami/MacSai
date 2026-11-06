import SwiftUI
import MacCleanKit

/// Kept outside the disabled app content so cancellation remains reachable
/// while existing work or the menu helper is still finishing.
struct SelfUpdatePreparationOverlay: View {
    let canCancel: Bool
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(L10n.tr("正在准备更新…", "Preparing update…", "Подготовка обновления…"))
            Text(L10n.tr("正在等待当前操作完成。", "Waiting for current operations to finish.", "Ожидание завершения текущих операций."))
                .font(.caption).foregroundStyle(.secondary)
            Button(L10n.tr("取消", "Cancel", "Отмена"), role: .cancel, action: onCancel)
                .keyboardShortcut(.cancelAction)
                .disabled(!canCancel)
                .accessibilityIdentifier("selfUpdateCancelPreparation")
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
