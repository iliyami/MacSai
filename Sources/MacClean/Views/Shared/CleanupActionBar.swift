import SwiftUI
import MacCleanKit

/// Keep the selection and its action together, with a stacked layout when
/// longer localized labels cannot fit alongside the button.
struct CleanupActionBar: View {
    let selectedCount: Int
    let totalCount: Int
    let selectedSize: UInt64
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 20) {
                selectionSummary.fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 8)
                cleanButton
            }
            VStack(alignment: .leading, spacing: 12) {
                selectionSummary
                HStack {
                    Spacer(minLength: 0)
                    cleanButton
                }
            }
        }
        .padding(16)
        .background(.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var selectionSummary: some View {
        Text(CleanupStrings.selectionSummary(selected: selectedCount, total: totalCount))
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
    }

    private var cleanButton: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(L10n.tr("清理", "Clean", "Очистить"))
                Text(FileSizeFormatter.format(selectedSize))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .buttonStyle(CleanupButtonStyle(gradient: gradient))
        .disabled(selectedCount == 0)
        .opacity(selectedCount == 0 ? 0.5 : 1)
        .help(selectedCount == 0
              ? L10n.tr("请至少勾选一个要清理的项目", "Select at least one item to clean", "Выберите хотя бы один объект для очистки")
              : L10n.tr("清理所选项目", "Clean selected items", "Очистить выбранные объекты"))
    }
}

private struct CleanupButtonStyle: ButtonStyle {
    let gradient: LinearGradient

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 20)
            .frame(minHeight: 44)
            .background(gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .brightness(configuration.isPressed ? -0.08 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

func cleanupConfirmationMessage(for categories: Set<ScanCategory>) -> String {
    var messages: [String] = []
    if !categories.subtracting([.trashBins, .universalBinaries]).isEmpty {
        messages.append(L10n.tr(
            "选中的文件会移到废纸篓，如有需要仍可恢复。",
            "Selected files will be moved to Trash so you can recover them if needed.",
            "Выбранные файлы будут перемещены в Корзину, откуда их можно восстановить."))
    }
    if categories.contains(.trashBins) {
        messages.append(L10n.tr(
            "废纸篓中选中的项目将永久删除，无法恢复。",
            "Selected items already in Trash will be permanently deleted and cannot be restored.",
            "Выбранные объекты из Корзины будут удалены безвозвратно."))
    }
    if categories.contains(.universalBinaries) {
        messages.append(L10n.tr(
            "应用中未使用的架构将被移除。恢复可能需要重新安装应用。",
            "Unused architectures will be removed from applications. Restoring them may require reinstalling the apps.",
            "Из приложений будут удалены лишние архитектуры. Для восстановления может потребоваться переустановка приложений."))
    }
    return messages.joined(separator: "\n\n")
}
