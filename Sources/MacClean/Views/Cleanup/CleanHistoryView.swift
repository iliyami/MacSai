import SwiftUI
import MacCleanKit

struct CleanHistoryView: View {
    @AppStorage("removeBackgroundColors") private var removeBackgroundColors = false
    @State private var sessions: [CleanHistorySession] = []
    @State private var pendingRestore: CleanHistorySession?
    @State private var lastSummary: CleanHistoryRestoreSummary?
    @State private var isRestoring = false
    @State private var confirmClear = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.tr("清理历史", "Clean History", "История очистки"))
                        .font(.system(size: 22, weight: .bold))
                    Text(L10n.tr(
                        "把最近一次清理整批恢复到原位置。已清空废纸篓或原路径已有文件的项会被跳过。",
                        "Put a whole clean back in one click. Items already emptied from the Trash, or with a new file at their original place, are skipped.",
                        "Верните всю очистку одним нажатием. Элементы, уже удалённые из Корзины, или те, на чьём месте появился новый файл, будут пропущены."
                    ))
                    .font(.system(size: 12))
                    .foregroundStyle(.primary.opacity(0.6))
                }
                Spacer()
                Button {
                    confirmClear = true
                } label: {
                    Label(L10n.tr("清除历史", "Clear History", "Очистить историю"), systemImage: "trash.slash")
                }
                .disabled(sessions.isEmpty || isRestoring)
                Button {
                    sessions = CleanHistoryRecorder.load()
                } label: {
                    Label(L10n.tr("刷新", "Refresh", "Обновить"), systemImage: "arrow.clockwise")
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Group {
                if sessions.isEmpty {
                    VStack {
                        Spacer()
                        Text(L10n.tr("还没有可恢复的清理记录", "No cleans to restore yet", "Пока нет очисток для восстановления"))
                            .foregroundStyle(.primary.opacity(0.4))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(sessions) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(size: 13, weight: .medium))
                                Text("\(Self.itemCount(session.items.count)) · \(FileSizeFormatter.format(session.totalBytes))")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                                if session.isPartial {
                                    Label(L10n.tr("部分可恢复", "Partly restorable", "Восстанавливается частично"),
                                          systemImage: "exclamationmark.triangle")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.orange)
                                }
                            }
                            Spacer()
                            Button(L10n.tr("恢复", "Restore", "Восстановить")) {
                                pendingRestore = session
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isRestoring)
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .background {
                if removeBackgroundColors { Color.clear }
                else { Rectangle().fill(.ultraThinMaterial) }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .task { sessions = CleanHistoryRecorder.load() }
        .alert(
            L10n.tr("恢复这次清理？", "Restore this clean?", "Восстановить эту очистку?"),
            isPresented: Binding(
                get: { pendingRestore != nil },
                set: { if !$0 { pendingRestore = nil } }
            ),
            presenting: pendingRestore
        ) { session in
            Button(L10n.tr("取消", "Cancel", "Отмена"), role: .cancel) { pendingRestore = nil }
            Button(L10n.tr("恢复", "Restore", "Восстановить")) {
                let target = session
                pendingRestore = nil
                isRestoring = true
                // File moves and stats stay off the main thread.
                Task {
                    defer { isRestoring = false }
                    guard let activity = try? await AppOperationActivity.shared.begin() else { return }
                    defer { AppOperationActivity.shared.end(activity) }
                    let summary = await Task.detached { CleanHistoryRecorder.restore(target) }.value
                    let reloaded = await Task.detached { CleanHistoryRecorder.load() }.value
                    lastSummary = summary
                    sessions = reloaded
                }
            }
        } message: { session in
            Text(Self.restoreMessage(for: session))
        }
        .alert(
            L10n.tr("恢复完成", "Restore finished", "Восстановление завершено"),
            isPresented: Binding(
                get: { lastSummary != nil },
                set: { if !$0 { lastSummary = nil } }
            )
        ) {
            Button(L10n.tr("好", "OK"), role: .cancel) { lastSummary = nil }
        } message: {
            if let lastSummary {
                Text(Self.summaryMessage(lastSummary))
            }
        }
        .alert(
            L10n.tr("清除清理历史？", "Clear clean history?", "Очистить историю очистки?"),
            isPresented: $confirmClear
        ) {
            Button(L10n.tr("取消", "Cancel", "Отмена"), role: .cancel) {}
            Button(L10n.tr("清除", "Clear", "Очистить"), role: .destructive) {
                CleanHistoryRecorder.clear()
                sessions = []
            }
        } message: {
            Text(L10n.tr(
                "这只会忘掉恢复记录，废纸篓里的文件不会被动。之后就不能一键恢复这些清理了。",
                "This only forgets the restore list. Nothing in the Trash is touched, but these cleans can no longer be restored in one click.",
                "Это удалит только список для восстановления. Файлы в Корзине останутся, но вернуть эти очистки одним нажатием будет нельзя."
            ))
        }
    }

    // Counts go through static, translatable format strings so every
    // language gets them (interpolated keys can't live in the fallback
    // dictionaries).

    static func itemCount(_ n: Int) -> String {
        String(format: L10n.tr(
            "%ld 项",
            n == 1 ? "%ld item" : "%ld items",
            "%ld \(L10n.russianPlural(n, one: "элемент", few: "элемента", many: "элементов"))"
        ), n)
    }

    static func restoreMessage(for session: CleanHistorySession) -> String {
        var lines = [
            itemCount(session.items.count),
            L10n.tr(
                "每一项都会放回原位置。原位置已有的文件绝不会被覆盖。",
                "Each item goes back to its original place. A file already at that place is never overwritten.",
                "Каждый элемент вернётся на прежнее место. Файл, который уже там лежит, никогда не перезаписывается."
            ),
        ]
        if let omitted = session.omittedCount, omitted > 0 {
            lines.append(String(format: L10n.tr(
                "这次清理太大，只能恢复前 %ld 项。其余 %ld 项仍在废纸篓中，可在访达里手动放回。",
                "This clean was too large to track in full: only the first %ld items can be restored. The other %ld are still in the Trash, and you can put them back from Finder.",
                "Эта очистка слишком большая: восстановить можно только первые %ld. Остальные (%ld) по-прежнему в Корзине, их можно вернуть через Finder."
            ), session.items.count, omitted))
        }
        return lines.joined(separator: "\n\n")
    }

    static func summaryMessage(_ summary: CleanHistoryRestoreSummary) -> String {
        var lines = [String(format: L10n.tr("已恢复：%ld", "Restored: %ld", "Восстановлено: %ld"), summary.restored)]
        if summary.emptied > 0 {
            lines.append(String(format: L10n.tr(
                "已从废纸篓清空：%ld", "Already emptied from the Trash: %ld", "Уже удалено из Корзины: %ld"
            ), summary.emptied))
        }
        if summary.reappeared > 0 {
            lines.append(String(format: L10n.tr(
                "原位置已有文件，已跳过：%ld", "Skipped, original place taken: %ld", "Пропущено, место занято: %ld"
            ), summary.reappeared))
        }
        if summary.failed > 0 {
            lines.append(String(format: L10n.tr(
                "无法恢复：%ld", "Couldn't restore: %ld", "Не удалось восстановить: %ld"
            ), summary.failed))
        }
        return lines.joined(separator: "\n")
    }
}
