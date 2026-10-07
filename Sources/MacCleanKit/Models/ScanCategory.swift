import Foundation

public enum ScanCategory: String, CaseIterable, Identifiable, Sendable {
    // System Junk
    case userCaches = "user_caches"
    case systemCaches = "system_caches"
    case userLogs = "user_logs"
    case systemLogs = "system_logs"
    case languageFiles = "language_files"
    case brokenPreferences = "broken_preferences"
    case brokenLoginItems = "broken_login_items"
    case documentVersions = "document_versions"
    case brokenDownloads = "broken_downloads"
    case iosDeviceBackups = "ios_device_backups"
    case oldUpdates = "old_updates"
    case universalBinaries = "universal_binaries"
    case xcodeJunk = "xcode_junk"
    case deletedUsers = "deleted_users"
    case unusedDiskImages = "unused_disk_images"
    case incompleteDownloads = "incomplete_downloads"
    case appLeftovers = "app_leftovers"
    case packageManagerCaches = "package_manager_caches"
    case ideCaches = "ide_caches"
    case aiToolCaches = "ai_tool_caches"

    // Mail
    case mailAttachments = "mail_attachments"

    // Trash
    case trashBins = "trash_bins"

    // Protection
    case malware = "malware"
    case browserPrivacy = "browser_privacy"
    case systemPrivacy = "system_privacy"

    // Files
    case largeFiles = "large_files"
    case oldFiles = "old_files"
    case duplicates = "duplicates"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .userCaches: L10n.tr("用户缓存文件", "User Cache Files", "Кэш пользователя")
        case .systemCaches: L10n.tr("系统缓存文件", "System Cache Files", "Системный кэш")
        case .userLogs: L10n.tr("用户日志文件", "User Log Files", "Журналы пользователя")
        case .systemLogs: L10n.tr("系统日志文件", "System Log Files", "Системные журналы")
        case .languageFiles: L10n.tr("语言文件", "Language Files", "Языковые файлы")
        case .brokenPreferences: L10n.tr("损坏的偏好设置", "Broken Preferences", "Повреждённые настройки")
        case .brokenLoginItems: L10n.tr("失效的登录项", "Broken Login Items", "Недействующие объекты входа")
        case .documentVersions: L10n.tr("文档版本", "Document Versions", "Версии документов")
        case .brokenDownloads: L10n.tr("残留下载文件", "Broken Downloads", "Остатки загрузок")
        case .iosDeviceBackups: L10n.tr("iOS 设备备份", "iOS Device Backups", "Резервные копии устройств iOS")
        case .oldUpdates: L10n.tr("旧更新文件", "Old Updates", "Старые обновления")
        case .universalBinaries: L10n.tr("通用二进制", "Universal Binaries", "Универсальные бинарные файлы")
        case .xcodeJunk: L10n.tr("Xcode 垃圾", "Xcode Junk", "Мусор Xcode")
        case .deletedUsers: L10n.tr("已删除用户数据", "Deleted Users", "Данные удалённых пользователей")
        case .unusedDiskImages: L10n.tr("未使用的磁盘映像", "Unused Disk Images", "Неиспользуемые образы дисков")
        case .incompleteDownloads: L10n.tr("未完成下载", "Incomplete Downloads", "Незавершённые загрузки")
        case .appLeftovers: L10n.tr("已删除应用的残留文件", "Leftovers from Deleted Apps", "Остатки удалённых приложений")
        case .packageManagerCaches: L10n.tr("包管理器缓存", "Package Manager Caches", "Кэш менеджеров пакетов")
        case .ideCaches: L10n.tr("IDE 与编辑器缓存", "IDE & Editor Caches", "Кэш IDE и редакторов")
        case .aiToolCaches: L10n.tr("AI 工具缓存", "AI Tool Caches", "Кэш AI-инструментов")
        case .mailAttachments: L10n.tr("邮件附件", "Mail Attachments", "Почтовые вложения")
        case .trashBins: L10n.tr("废纸篓", "Trash Bins", "Корзины")
        case .malware: L10n.tr("恶意软件", "Malware", "Вредоносное ПО")
        case .browserPrivacy: L10n.tr("浏览器隐私", "Browser Privacy", "Конфиденциальность браузеров")
        case .systemPrivacy: L10n.tr("系统隐私", "System Privacy", "Конфиденциальность системы")
        case .largeFiles: L10n.tr("大文件", "Large Files", "Большие файлы")
        case .oldFiles: L10n.tr("旧文件", "Old Files", "Старые файлы")
        case .duplicates: L10n.tr("重复文件", "Duplicates", "Дубликаты")
        }
    }

    /// One-line description shown under the category name in the results list.
    public var subtitle: String {
        switch self {
        case .userCaches: L10n.tr("应用临时文件，下次启动会重新生成。", "App temporary files. Regenerated next launch.", "Временные файлы приложений. Будут созданы заново при следующем запуске.")
        case .systemCaches: L10n.tr("由 macOS 管理的缓存，会自动重建。", "macOS-managed caches. Rebuilt automatically.", "Кэши под управлением macOS. Восстанавливаются автоматически.")
        case .userLogs: L10n.tr("应用写入的诊断日志。", "Diagnostic logs written by your apps.", "Диагностические журналы приложений.")
        case .systemLogs: L10n.tr("macOS 诊断日志。", "macOS diagnostic logs.", "Диагностические журналы macOS.")
        case .languageFiles: L10n.tr("应用内未使用的本地化语言资源。", "Unused localizations bundled with apps.", "Неиспользуемые локализации, встроенные в приложения.")
        case .brokenPreferences: L10n.tr("损坏或孤立的偏好设置文件。", "Corrupt or orphaned preference files.", "Повреждённые или оставшиеся без приложения файлы настроек.")
        case .brokenLoginItems: L10n.tr("指向已不存在应用的登录项。", "Login items pointing at apps that are gone.", "Объекты входа, ведущие к удалённым приложениям.")
        case .documentVersions: L10n.tr("旧的自动保存文档版本。", "Old autosaved document revisions.", "Старые автоматически сохранённые версии документов.")
        case .brokenDownloads: L10n.tr("失败或孤立下载留下的文件。", "Failed or orphaned download leftovers.", "Остатки неудачных или потерянных загрузок.")
        case .iosDeviceBackups: L10n.tr("iPhone 和 iPad 的本地备份。", "Local backups of iPhone and iPad devices.", "Локальные резервные копии устройств iPhone и iPad.")
        case .oldUpdates: L10n.tr("更新后遗留的安装包。", "Installer packages left behind after updating.", "Установочные пакеты, оставшиеся после обновлений.")
        case .universalBinaries: L10n.tr("应用二进制中未使用的 CPU 架构切片。", "Unused CPU slices inside app binaries.", "Неиспользуемые срезы архитектур CPU в бинарных файлах приложений.")
        case .xcodeJunk: L10n.tr("派生数据、归档和模拟器缓存。", "Derived data, archives, and simulator caches.", "Derived Data, архивы и кэши симуляторов.")
        case .deletedUsers: L10n.tr("已移除用户账户留下的数据。", "Leftover data from removed user accounts.", "Данные, оставшиеся от удалённых учётных записей.")
        case .unusedDiskImages: L10n.tr("曾经挂载但已不再需要的磁盘映像。", "Disk images you mounted once and forgot.", "Образы дисков, которые были смонтированы и больше не нужны.")
        case .incompleteDownloads: L10n.tr("未下载完成的文件。", "Partially downloaded files.", "Частично загруженные файлы.")
        case .appLeftovers: L10n.tr("已删除应用留下的支持文件。", "Support files from apps you've deleted.", "Служебные файлы удалённых приложений.")
        case .packageManagerCaches: L10n.tr("npm、Cargo、pip、Homebrew、Gradle 的可重建缓存。", "Regenerable caches from npm, Cargo, pip, Homebrew, and Gradle.", "Восстанавливаемые кэши npm, Cargo, pip, Homebrew и Gradle.")
        case .ideCaches: L10n.tr("代码编辑器的缓存（Cursor、Antigravity 等）。", "Caches from code editors like Cursor and Antigravity.", "Кэши редакторов кода, таких как Cursor и Antigravity.")
        case .aiToolCaches: L10n.tr("AI 编码工具的缓存（Claude、Codex）；不含历史与会话。", "Caches from AI coding tools (Claude, Codex). History and sessions excluded.", "Кэши AI-инструментов для программирования (Claude, Codex). История и сеансы не затрагиваются.")
        case .mailAttachments: L10n.tr("邮件附件的缓存副本。", "Saved copies of Mail attachments.", "Кэшированные копии почтовых вложений.")
        case .trashBins: L10n.tr("当前位于废纸篓中的项目。", "Items currently sitting in the Trash.", "Объекты, находящиеся в Корзине.")
        case .malware: L10n.tr("在磁盘上发现的已知恶意文件。", "Known malicious files found on disk.", "Известные вредоносные файлы, найденные на диске.")
        case .browserPrivacy: L10n.tr("浏览历史和跟踪数据；Cookie 与会话会保留。", "Browsing history and tracking data. Cookies and sessions stay.", "История браузера и данные отслеживания. Cookie и сеансы сохраняются.")
        case .systemPrivacy: L10n.tr("最近项目列表和其他隐私痕迹。", "Recent-items lists and other privacy traces.", "Списки недавних объектов и другие следы активности.")
        case .largeFiles: L10n.tr("占用空间最多的文件。", "The files taking up the most space.", "Файлы, занимающие больше всего места.")
        case .oldFiles: L10n.tr("长时间未打开的文件。", "Files you haven't opened in a long time.", "Файлы, которые давно не открывались.")
        case .duplicates: L10n.tr("同一文件的相同副本。", "Identical copies of the same file.", "Идентичные копии одного файла.")
        }
    }

    /// Full hover explanation for a category header.
    ///
    /// The header row renders the name and the subtitle on one truncating line
    /// each, so a narrow window (or a long localization) hides the end of
    /// either. The tooltip always carries both in full, which is the only place
    /// a user can read what a category like "Broken Login Items" actually
    /// contains before deciding to clean it.
    public var tooltip: String {
        "\(displayName)\n\(subtitle)"
    }

    /// How safe a category is to clean, shown as a badge on the review screen.
    public enum CleanupSafety: CaseIterable, Sendable {
        /// macOS or the owning app rebuilds it on its own.
        case regenerates
        /// Gone for good once cleaned, but nothing on the Mac uses it.
        case safeToRemove
        /// The user's own data, or only reversible by re-downloading.
        case reviewFirst

        public var label: String {
            switch self {
            case .regenerates: L10n.tr("会自动重建", "Recreated automatically", "Создаётся заново автоматически")
            case .safeToRemove: L10n.tr("可安全移除", "Safe to remove", "Можно безопасно удалить")
            case .reviewFirst: L10n.tr("清理前请检查", "Review before cleaning", "Проверьте перед очисткой")
            }
        }

        public var systemImage: String {
            switch self {
            case .regenerates: "arrow.triangle.2.circlepath.circle"
            case .safeToRemove: "checkmark.shield"
            case .reviewFirst: "exclamationmark.shield"
            }
        }
    }

    /// Only categories that genuinely come back on their own may claim
    /// `.regenerates`; see `ScanCategorySafetyTests`.
    public var cleanupSafety: CleanupSafety {
        switch self {
        case .userCaches, .systemCaches, .packageManagerCaches, .ideCaches, .aiToolCaches:
            .regenerates
        case .userLogs, .systemLogs, .brokenPreferences, .brokenLoginItems,
             .brokenDownloads, .incompleteDownloads, .oldUpdates, .appLeftovers:
            .safeToRemove
        case .languageFiles, .documentVersions, .iosDeviceBackups, .universalBinaries,
             .xcodeJunk, .deletedUsers, .unusedDiskImages, .mailAttachments, .trashBins,
             .malware, .browserPrivacy, .systemPrivacy, .largeFiles, .oldFiles, .duplicates:
            .reviewFirst
        }
    }

    /// Why cleaning this category is safe, or what to check before doing it.
    /// Explanation only: it never changes what gets cleaned.
    public var safetyRationale: String {
        switch self {
        case .userCaches: L10n.tr("应用临时文件。每个应用下次启动时会自动重新生成。", "App temp files. Recreated automatically the next time each app launches.", "Временные файлы приложений. Создаются заново автоматически при следующем запуске каждого приложения.")
        case .systemCaches: L10n.tr("由 macOS 自行管理的缓存，需要时会自动重建。", "Caches macOS manages itself. It rebuilds them automatically as needed.", "Кэши, которыми управляет сама macOS. Она восстанавливает их автоматически по мере необходимости.")
        case .packageManagerCaches: L10n.tr("下载和构建缓存。npm、Cargo、pip、Homebrew 和 Gradle 会在下次安装或构建时重新下载所需内容。", "Download and build caches. npm, Cargo, pip, Homebrew, and Gradle re-download what they need on the next install or build.", "Кэши загрузок и сборок. npm, Cargo, pip, Homebrew и Gradle заново скачают нужное при следующей установке или сборке.")
        case .ideCaches: L10n.tr("仅编辑器缓存。Cursor 和 Antigravity 下次启动时会重新生成；你的设置和扩展不受影响。", "Editor caches only. Cursor and Antigravity recreate them on next launch; your settings and extensions aren't touched.", "Только кэши редакторов. Cursor и Antigravity создадут их заново при следующем запуске; настройки и расширения не затрагиваются.")
        case .aiToolCaches: L10n.tr("仅临时和缓存文件夹。Claude 和 Codex 会按需重新生成；绝不包含历史、记忆和会话。", "Scratch and cache folders only. Claude and Codex recreate them as needed; history, memory, and sessions are never included.", "Только временные папки и кэши. Claude и Codex создадут их заново при необходимости; история, память и сеансы никогда не включаются.")
        case .userLogs: L10n.tr("应用为排查问题写下的诊断记录。应用不会回读旧日志，运行时会写新的日志。", "Diagnostic text your apps wrote for troubleshooting. Apps don't read old logs back, and they start new ones as they run.", "Диагностические записи, которые приложения вели для поиска неполадок. Старые журналы приложения не читают и при работе начинают новые.")
        case .systemLogs: L10n.tr("macOS 诊断日志。仅在排查过去的问题时有用；macOS 会继续写入新日志。", "macOS diagnostic logs. Only useful when investigating a past problem; macOS keeps writing fresh ones.", "Диагностические журналы macOS. Нужны только для разбора прошлых проблем; macOS продолжает вести новые.")
        case .brokenPreferences: L10n.tr("无法读取的设置文件，或其应用已不再安装。这台 Mac 上没有任何东西在使用它们。", "Settings files that can't be read, or whose app is no longer installed. Nothing on this Mac uses them.", "Файлы настроек, которые не читаются или чьё приложение больше не установлено. На этом Mac их ничто не использует.")
        case .brokenLoginItems: L10n.tr("指向已不存在应用的登录项，因此无法启动任何东西。", "Login entries that point to apps that no longer exist, so they can't start anything.", "Записи входа, ведущие к уже несуществующим приложениям, поэтому они ничего не запускают.")
        case .brokenDownloads: L10n.tr("失败或被放弃的下载留下的文件。如仍需要，请重新下载。", "Leftovers of downloads that failed or were abandoned. Download the file again if you still want it.", "Остатки неудавшихся или брошенных загрузок. Если файл ещё нужен, скачайте его снова.")
        case .incompleteDownloads: L10n.tr("未完成下载的部分文件和超过一天的临时文件。下载仍在进行时请勿清理。", "Partial files from unfinished downloads and day-old temp files. Don't clean while a download is still running.", "Части файлов от незавершённых загрузок и временные файлы старше суток. Не очищайте, пока загрузка ещё идёт.")
        case .oldUpdates: L10n.tr("应用在一周多以前下载的安装包。安装程序运行后就不再需要，需要时可重新下载。", "Installer packages apps downloaded more than a week ago. Installers aren't needed once they've run, and can be downloaded again.", "Установочные пакеты, скачанные приложениями больше недели назад. После установки они не нужны, при необходимости их можно скачать снова.")
        case .appLeftovers: L10n.tr("以已不再安装的应用命名的支持文件夹（每行的名称就是该应用的 ID）。以后重新安装该应用会从头开始。", "Support folders named after an app that's no longer installed (the name on each row is that app's ID). Reinstalling the app later starts it fresh.", "Служебные папки, названные по приложению, которое больше не установлено (имя в каждой строке — ID этого приложения). При повторной установке приложение начнёт с чистого листа.")
        case .languageFiles: L10n.tr("你不使用的语言翻译。移除会修改应用包；如需恢复请重新安装应用。", "Translations for languages you don't use. Removing them changes the app bundle; reinstall the app to get them back.", "Переводы на языки, которыми вы не пользуетесь. Удаление меняет пакет приложения; чтобы вернуть их, переустановите приложение.")
        case .documentVersions: L10n.tr("文档的旧自动保存版本。当前版本会保留，但清理后无法再浏览旧版本。", "Older autosaved revisions of your documents. The current version stays, but older ones can't be browsed after cleaning.", "Старые автосохранённые версии ваших документов. Текущая версия остаётся, но к старым после очистки вернуться нельзя.")
        case .iosDeviceBackups: L10n.tr("超过 30 天的 iPhone 和 iPad 本地备份。如果这是设备唯一的备份，请保留或先备份到 iCloud。", "Local iPhone and iPad backups older than 30 days. If it's a device's only backup, keep it or back up to iCloud first.", "Локальные резервные копии iPhone и iPad старше 30 дней. Если это единственная копия устройства, оставьте её или сначала сделайте копию в iCloud.")
        case .universalBinaries: L10n.tr("从应用中移除这台 Mac 无法运行的 CPU 代码。会直接修改应用；只有重新安装才能撤销。", "Removes CPU code this Mac can't run from inside apps. Changes the apps in place; only reinstalling them undoes it.", "Удаляет из приложений код для процессоров, которые этот Mac не использует. Приложения меняются на месте; отменить можно только переустановкой.")
        case .xcodeJunk: L10n.tr("DerivedData 和 Previews 会在下次构建时重建，Device Support 会在连接设备时重新复制。Archives 和模拟器数据无法重新生成；如需旧构建或崩溃符号请保留。", "DerivedData and Previews are rebuilt on the next build, and Device Support is copied again when a device connects. Archives and simulator data can't be regenerated; keep them if you need old builds or crash symbols.", "DerivedData и Previews пересобираются при следующей сборке, Device Support копируется заново при подключении устройства. Archives и данные симуляторов восстановить нельзя; оставьте их, если нужны старые сборки или символы сбоев.")
        case .deletedUsers: L10n.tr("已不在这台 Mac 上的账户的整个个人文件夹。请逐个核对名称：暂时离线的网络账户看起来完全一样。", "Whole home folders of accounts no longer on this Mac. Check each name: a network account that's briefly offline looks the same.", "Целые домашние папки учётных записей, которых больше нет на этом Mac. Проверьте каждое имя: временно недоступная сетевая учётная запись выглядит так же.")
        case .unusedDiskImages: L10n.tr("下载文件夹中超过一周的磁盘映像，通常是已运行过的安装程序。如需要可重新下载。", "Disk images in Downloads older than a week, usually installers that already ran. Download them again if you need them.", "Образы дисков в Загрузках старше недели, обычно уже использованные установщики. При необходимости скачайте их снова.")
        case .mailAttachments: L10n.tr("邮件保存在磁盘上的附件副本。IMAP 和 Exchange 账户可从服务器重新下载，POP 账户不行。", "Copies of attachments Mail saved on disk. Mail can download them again from the server for IMAP and Exchange accounts, not for POP.", "Копии вложений, сохранённые Почтой на диске. Для IMAP и Exchange Почта может скачать их с сервера снова, для POP — нет.")
        case .trashBins: L10n.tr("已在废纸篓中。清倒是永久性的，无法撤销。", "Already in the Trash. Emptying it is permanent and can't be undone.", "Уже в Корзине. Очистка окончательная, её нельзя отменить.")
        case .malware: L10n.tr("匹配已知恶意软件特征。如果它属于你有意安装的软件，请先检查路径。", "Matched a known malware signature. Check the path first if it belongs to software you installed on purpose.", "Совпадает с известной сигнатурой вредоносного ПО. Если это программа, установленная вами намеренно, сначала проверьте путь.")
        case .browserPrivacy: L10n.tr("你的浏览历史和跟踪数据。清理后无法恢复；Cookie 和登录会话会保留。", "Your browsing history and tracking data. Can't be restored after cleaning; cookies and logged-in sessions stay.", "История браузера и данные отслеживания. После очистки восстановить нельзя; cookie и активные входы сохраняются.")
        case .systemPrivacy: L10n.tr("最近项目列表和类似痕迹。应用的“最近打开”菜单将会清空。", "Recent-items lists and similar traces. Apps' Open Recent menus will start empty.", "Списки недавних объектов и похожие следы. Меню «Недавние» в приложениях станут пустыми.")
        case .largeFiles: L10n.tr("你自己的文件，仅按大小挑选。这里没有任何东西天生就是垃圾；请逐个检查。", "Your own files, picked only by size. Nothing here is junk by definition; check each one.", "Ваши собственные файлы, отобранные только по размеру. Мусором они не являются по определению; проверьте каждый.")
        case .oldFiles: L10n.tr("很久没打开过的你自己的文件。旧并不代表不需要；请逐个检查。", "Your own files you haven't opened in a long time. Old doesn't mean unneeded; check each one.", "Ваши файлы, которые давно не открывались. Старый — не значит ненужный; проверьте каждый.")
        case .duplicates: L10n.tr("逐字节完全相同的副本。每个需要的文件请至少保留一份。", "Byte-for-byte identical copies. Keep at least one copy of each file you need.", "Побайтово идентичные копии. Оставьте хотя бы одну копию каждого нужного файла.")
        }
    }

    public var systemImage: String {
        switch self {
        case .userCaches, .systemCaches: "folder.badge.gearshape"
        case .userLogs, .systemLogs: "doc.text"
        case .languageFiles: "globe"
        case .brokenPreferences: "gearshape.triangle.fill"
        case .brokenLoginItems: "person.crop.circle.badge.exclamationmark"
        case .documentVersions: "doc.on.doc"
        case .brokenDownloads, .incompleteDownloads: "arrow.down.circle.dotted"
        case .iosDeviceBackups: "iphone"
        case .oldUpdates: "arrow.triangle.2.circlepath"
        case .universalBinaries: "cpu"
        case .xcodeJunk: "hammer"
        case .deletedUsers: "person.crop.circle.badge.minus"
        case .unusedDiskImages: "opticaldisc"
        case .appLeftovers: "shippingbox.and.arrow.backward"
        case .packageManagerCaches: "shippingbox"
        case .ideCaches: "macwindow"
        case .aiToolCaches: "sparkles"
        case .mailAttachments: "paperclip"
        case .trashBins: "trash"
        case .malware: "shield.lefthalf.filled.trianglebadge.exclamationmark"
        case .browserPrivacy: "safari"
        case .systemPrivacy: "hand.raised"
        case .largeFiles: "arrow.up.right.square"
        case .oldFiles: "clock.arrow.circlepath"
        case .duplicates: "plus.square.on.square"
        }
    }

    public var autoSelect: Bool {
        switch self {
        case .unusedDiskImages, .largeFiles, .oldFiles, .duplicates,
             .universalBinaries, .appLeftovers, .deletedUsers,
             .packageManagerCaches, .ideCaches, .aiToolCaches:
            // appLeftovers: deletes another app's leftover data; detection is
            // conservative but never auto-checked — the user reviews first.
            // universalBinaries: thinning rewrites the app's binaries in
            // place (lipo preserves their signatures; we never re-sign).
            // Still only reversible by re-downloading the app, so don't
            // pre-check — force explicit consent.
            // deletedUsers: flags an entire /Users/<name> home folder based
            // on it being absent from `dscl . -list /Users` at scan time —
            // a network/mobile account that's briefly unreachable would
            // look identical to a genuinely removed one. Never pre-check;
            // the user must look at the name and confirm each one.
            false
        default:
            true
        }
    }
}
