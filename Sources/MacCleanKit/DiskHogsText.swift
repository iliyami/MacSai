import Foundation

/// User-facing copy for the Disk Hogs module. Kept static (no interpolation)
/// so every string resolves through the de, fr and zh-Hant dictionaries.
public enum DiskHogsText {
    public static var title: String { L10n.tr("开发者磁盘占用", "Disk Hogs", "Дисковые «пожиратели»") }
    public static var subtitle: String {
        L10n.tr(
            "Docker 和 Xcode 模拟器占用的空间。只显示在这台 Mac 上找到的工具，且不会自动勾选任何项目。",
            "Space used by Docker and Xcode simulators. Only the tools found on this Mac are shown, and nothing is selected for you.",
            "Место, занятое Docker и симуляторами Xcode. Показаны только инструменты, найденные на этом Mac, и ничего не выбирается заранее."
        )
    }
    public static var refresh: String { L10n.tr("刷新", "Refresh", "Обновить") }
    public static var size: String { L10n.tr("大小", "Size", "Размер") }
    public static var xcodeSection: String { L10n.tr("Xcode 模拟器", "Xcode Simulators", "Симуляторы Xcode") }
    public static var unavailableSimulator: String { L10n.tr("不可用的模拟器", "Unavailable simulator", "Недоступный симулятор") }
    public static var olderRuntime: String { L10n.tr("旧版运行时", "Older runtime", "Старый рантайм") }
    public static var pruneButton: String {
        L10n.tr("清理所选 Docker 项目…", "Prune Selected Docker Items…", "Очистить выбранное в Docker…")
    }
    public static var deleteButton: String {
        L10n.tr("删除所选模拟器项目…", "Delete Selected Simulator Items…", "Удалить выбранные элементы симуляторов…")
    }
    public static var dockerNotResponding: String {
        L10n.tr(
            "已找到 Docker，但它没有响应。请先启动 Docker Desktop，然后点“刷新”。",
            "Docker is installed but not responding. Start Docker Desktop, then click Refresh.",
            "Docker установлен, но не отвечает. Запустите Docker Desktop и нажмите «Обновить»."
        )
    }
    public static var dockerDiskImage: String {
        L10n.tr("Docker Desktop 磁盘映像", "Docker Desktop disk image", "Образ диска Docker Desktop")
    }
    public static var dockerDiskImageNote: String {
        L10n.tr(
            "Docker 的虚拟磁盘，里面存放着你所有的镜像、容器和卷，所以 Mac Sai 绝不会删除它。清理 Docker 项目会释放其中的空间，Docker Desktop 随后会把空间还给 macOS。如需限制它的大小，请在 Docker Desktop 的“资源”设置中调低磁盘上限。",
            "Docker's virtual disk. It holds all your images, containers, and volumes, so Mac Sai never deletes it. Pruning Docker items frees space inside it, and Docker Desktop then gives that space back to macOS. To cap its size, lower the disk limit in Docker Desktop's Resources settings.",
            "Виртуальный диск Docker. На нём хранятся все образы, контейнеры и тома, поэтому Mac Sai никогда его не удаляет. Очистка элементов Docker освобождает место внутри него, а Docker Desktop затем возвращает это место macOS. Чтобы ограничить его размер, уменьшите лимит диска в настройках ресурсов Docker Desktop."
        )
    }
    public static var nothingFound: String {
        L10n.tr(
            "这台 Mac 上没有找到 Docker 或 Xcode 模拟器。",
            "No Docker or Xcode simulators found on this Mac.",
            "На этом Mac не найдены ни Docker, ни симуляторы Xcode."
        )
    }
    public static var pruneConfirmTitle: String {
        L10n.tr("永久清理所选 Docker 项目？", "Permanently prune the selected Docker items?", "Безвозвратно очистить выбранное в Docker?")
    }
    public static var pruneConfirmButton: String { L10n.tr("永久清理", "Prune Permanently", "Очистить безвозвратно") }
    public static var deleteConfirmTitle: String {
        L10n.tr("永久删除所选模拟器项目？", "Permanently delete the selected simulator items?", "Безвозвратно удалить выбранные элементы симуляторов?")
    }
    public static var deleteConfirmButton: String { L10n.tr("永久删除", "Delete Permanently", "Удалить безвозвратно") }
    public static var runtimeShutdownNote: String {
        L10n.tr(
            "删除运行时会先关闭正在使用它的模拟器，这些模拟器之后将不可用。",
            "Deleting a runtime first shuts down any simulator using it, and those simulators become unavailable.",
            "Перед удалением рантайма все симуляторы, которые его используют, будут выключены и станут недоступны."
        )
    }
    public static var permanentNote: String {
        L10n.tr("此操作不可撤销，不会进入废纸篓。", "This is permanent. Nothing goes to the Trash.", "Это необратимо: ничего не попадёт в Корзину.")
    }
    public static var cancel: String { L10n.tr("取消", "Cancel", "Отмена") }
    public static var pruned: String { L10n.tr("清理完成", "Pruned", "Очищено") }
    public static var deleted: String { L10n.tr("删除完成", "Deleted", "Удалено") }
    public static var failed: String { L10n.tr("未能完成", "Failed", "Не удалось") }
    public static var timedOut: String { L10n.tr("超时，已停止", "Timed out and was stopped", "Превышено время ожидания, остановлено") }
    public static var stopped: String { L10n.tr("已停止", "Stopped", "Остановлено") }

    /// Every string above, for the translation coverage test.
    static var all: [String] {
        [title, subtitle, refresh, size, xcodeSection, unavailableSimulator, olderRuntime, pruneButton,
         deleteButton, dockerNotResponding, dockerDiskImage, dockerDiskImageNote, nothingFound, pruneConfirmTitle, pruneConfirmButton,
         deleteConfirmTitle, deleteConfirmButton, runtimeShutdownNote, permanentNote, cancel, pruned,
         deleted, failed, timedOut, stopped]
        + DockerDiskCategory.allCases.flatMap { [$0.label, $0.pruneNote] }
    }

    /// One status line per prune or delete: "Images: Pruned", or the failure
    /// with the command's own first error line.
    public static func statusLine(name: String, outcome: BoundedProcess.Outcome, success: String) -> String {
        switch outcome {
        case .exited(0, _, _):
            return "\(name): \(success)"
        case .timedOut:
            return "\(name): \(timedOut)"
        case .cancelled:
            return "\(name): \(stopped)"
        case .exited, .launchFailed:
            let detail = outcome.failureDetail
            return detail.isEmpty ? "\(name): \(failed)" : "\(name): \(failed) (\(detail))"
        }
    }
}
