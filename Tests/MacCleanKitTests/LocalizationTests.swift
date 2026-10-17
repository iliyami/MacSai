import XCTest

@testable import MacCleanKit

final class LocalizationTests: AppLanguageTestCase {
    func testJapaneseLanguageSelectionAndRegionalIdentifiers() {
        XCTAssertTrue(AppLanguage.allCases.contains(.ja))
        XCTAssertEqual(AppLanguage.ja.rawValue, "ja")
        XCTAssertEqual(AppLanguage.ja.pickerLabel, "日本語")
        XCTAssertEqual(AppLanguage.ja.localeIdentifier, "ja")
        for identifier in ["ja", "ja-JP", "ja_JP", "JA-jp"] {
            XCTAssertEqual(AppLanguage.preferredLanguage(for: identifier), .ja, identifier)
        }
    }

    func testJapaneseTranslationOverloadsAndFallbacks() {
        AppLanguage.current = .ja
        XCTAssertEqual(L10n.tr("设置", "Settings"), "設定")
        XCTAssertEqual(L10n.tr("设置", "Settings", "Настройки"), "設定")
        XCTAssertEqual(L10n.tr("设置"), "設定")
        XCTAssertEqual(MaintenanceTask.freeUpRAM.title, "RAM を解放")
        XCTAssertEqual(ScanCategory.userCaches.displayName, "ユーザーキャッシュファイル")
        XCTAssertEqual(FileListSort.sizeDescending.label, "サイズの大きい順")
        XCTAssertEqual(L10n.tr("未翻译", "New feature"), "New feature")
        XCTAssertEqual(L10n.tr("未翻译", "New feature", "Russian"), "New feature")
        XCTAssertEqual(L10n.tr("未翻译"), "未翻译")
        for count in [1, 2] {
            let english = "\(count) threat\(count == 1 ? "" : "s") found"
            XCTAssertEqual(L10n.tr("发现 \(count) 个威胁", english), english)
            XCTAssertEqual(L10n.tr("发现 \(count) 个威胁", english, "Russian"), english)
        }
    }

    func testJapaneseLanguageResourcesCannotBeOfferedForCleanup() {
        let original = LanguagePreferences.discoveredLproj
        defer { LanguagePreferences.discoveredLproj = original }
        let folders: Set<String> = ["ja.lproj", "ja-JP.lproj", "ja_JP.lproj", "Japanese.lproj"]
        LanguagePreferences.discoveredLproj = folders
        XCTAssertTrue(folders.isSubset(of: LanguagePreferences.alwaysKept))
        XCTAssertTrue(LanguagePreferences.selectableLanguages().isEmpty)
    }

    func testGermanLanguageSelectionAndRegionalIdentifiers() {
        XCTAssertTrue(AppLanguage.allCases.contains(.de))
        XCTAssertEqual(AppLanguage.de.pickerLabel, "Deutsch")
        XCTAssertEqual(AppLanguage.de.localeIdentifier, "de")
        for identifier in ["de-DE", "de_AT", "DE-ch", "de"] {
            XCTAssertEqual(AppLanguage.preferredLanguage(for: identifier), .de)
        }
    }

    func testGermanUsesEveryTranslationOverloadAndModelLabels() {
        AppLanguage.current = .de
        XCTAssertEqual(L10n.tr("设置", "Settings"), "Einstellungen")
        XCTAssertEqual(L10n.tr("设置", "Settings", "Настройки"), "Einstellungen")
        XCTAssertEqual(L10n.tr("设置"), "Einstellungen")
        XCTAssertEqual(L10n.tr("跟随系统", "System", "Системный"), "System")
        XCTAssertEqual(MaintenanceTask.freeUpRAM.title, "Arbeitsspeicher freigeben")
        XCTAssertEqual(ScanCategory.userCaches.displayName, "Benutzer-Cache-Dateien")
        XCTAssertEqual(FileListSort.sizeDescending.label, "Größte zuerst")
    }

    func testGermanFallbackPreservesDynamicEnglishPluralForms() {
        AppLanguage.current = .de
        for count in [1, 2] {
            let english = "\(count) threat\(count == 1 ? "" : "s") found"
            XCTAssertEqual(L10n.tr("发现 \(count) 个威胁", english), english)
            XCTAssertEqual(L10n.tr("发现 \(count) 个威胁", english, "Russian"), english)
        }
        XCTAssertEqual(L10n.tr("未翻译", "New feature"), "New feature")
        XCTAssertEqual(L10n.tr("未翻译"), "未翻译")
    }

    func testGermanLanguageResourcesCannotBeOfferedForCleanup() {
        for folder in ["de.lproj", "de-DE.lproj", "de_AT.lproj", "de-CH.lproj", "German.lproj"] {
            XCTAssertTrue(LanguagePreferences.alwaysKept.contains(folder))
        }
    }

    func testRussianIsSelectableAndUsesRussianLocale() {
        XCTAssertTrue(AppLanguage.allCases.contains(.ru))
        XCTAssertEqual(AppLanguage.ru.rawValue, "ru")
        XCTAssertEqual(AppLanguage.ru.localeIdentifier, "ru")
        XCTAssertEqual(AppLanguage.ru.pickerLabel, "Русский")
    }

    func testPreferredLanguageRecognizesRussianIdentifiers() {
        XCTAssertEqual(AppLanguage.preferredLanguage(for: "ru-RU"), .ru)
        XCTAssertEqual(AppLanguage.preferredLanguage(for: "ru_KZ"), .ru)
        XCTAssertEqual(AppLanguage.preferredLanguage(for: "RU_ru"), .ru)
        XCTAssertEqual(AppLanguage.preferredLanguage(for: "zh-Hans-CN"), .zhHans)
        XCTAssertEqual(AppLanguage.preferredLanguage(for: "en-US"), .en)
        XCTAssertEqual(AppLanguage.preferredLanguage(for: "de-DE"), .de)
    }

    func testThreeLanguageTranslation() {
        AppLanguage.current = .ru
        XCTAssertEqual(L10n.tr("设置", "Settings", "Настройки"), "Настройки")

        AppLanguage.current = .en
        XCTAssertEqual(L10n.tr("设置", "Settings", "Настройки"), "Settings")

        AppLanguage.current = .zhHans
        XCTAssertEqual(L10n.tr("设置", "Settings", "Настройки"), "设置")
    }

    func testRussianDynamicFallbackTranslation() {
        AppLanguage.current = .ru
        XCTAssertEqual(L10n.tr("设置"), "Настройки")
        XCTAssertEqual(L10n.tr("未知键"), "未知键")
    }

    func testUntranslatedStringFallsBackToEnglishInRussian() {
        AppLanguage.current = .ru
        XCTAssertEqual(L10n.tr("新功能", "New feature"), "New feature")
    }

    func testKnownTwoArgumentStringUsesRussianFallback() {
        AppLanguage.current = .ru

        let cases = [
            ("可用磁盘空间", "Free disk space", "Свободное место на диске"),
            ("GPU 使用率", "GPU usage", "Загрузка GPU"),
            ("内存使用率", "Memory usage", "Использование памяти"),
            ("电池温度", "Battery temperature", "Температура аккумулятора"),
            ("菜单栏显示", "Menu bar display", "Показатель в строке меню"),
            (
                "选择应用图标旁显示的紧凑数值。GPU 或电池温度不可用时显示 --。",
                "Choose the compact value shown next to the app icon. Unavailable GPU or battery sensors appear as --.",
                "Выберите компактный показатель рядом со значком приложения. Если данные GPU или температуры аккумулятора недоступны, отображается --."
            ),
        ]

        for (chinese, english, russian) in cases {
            XCTAssertEqual(L10n.tr(chinese, english), russian)
        }
    }

    func testRussianPluralRules() {
        let cases: [(Int, String)] = [
            (0, "файлов"), (1, "файл"), (2, "файла"), (4, "файла"), (5, "файлов"),
            (11, "файлов"), (12, "файлов"), (14, "файлов"), (21, "файл"),
            (22, "файла"), (25, "файлов"), (101, "файл"), (111, "файлов"),
        ]

        for (count, expected) in cases {
            XCTAssertEqual(
                L10n.russianPlural(count, one: "файл", few: "файла", many: "файлов"),
                expected,
                "Unexpected Russian plural for \(count)"
            )
        }
    }

    func testFileTypeCategoryLabelsFollowRussianLanguage() {
        AppLanguage.current = .ru
        XCTAssertEqual(FileTypeCategory.folders.label, "Папки")
        XCTAssertEqual(FileTypeCategory.diskImages.label, "Образы дисков")
        XCTAssertEqual(FileTypeCategory.other.label, "Другое")
    }

    func testMaintenanceTaskMetadataFollowsRussianLanguage() {
        AppLanguage.current = .ru

        XCTAssertEqual(MaintenanceTask.freeUpRAM.title, "Освободить ОЗУ")
        XCTAssertEqual(
            MaintenanceTask.flushDNSCache.description,
            "Очистить локальный кэш DNS и принудительно обновить разрешение имён"
        )
        XCTAssertTrue(MaintenanceTask.rebuildLaunchServices.sideEffects.contains("час"))
    }

    func testScanCategoryMetadataFollowsRussianLanguage() {
        AppLanguage.current = .ru

        XCTAssertEqual(ScanCategory.userCaches.displayName, "Кэш пользователя")
        XCTAssertEqual(
            ScanCategory.userCaches.subtitle,
            "Временные файлы приложений. Будут созданы заново при следующем запуске."
        )
    }

    func testFileGroupingAndSortLabelsFollowRussianLanguage() {
        AppLanguage.current = .ru

        XCTAssertEqual(FileGroup.fileTypeLabel("mp4"), "Видео")
        XCTAssertEqual(FileGroup.ageLabel(days: 400), "Более 1 года")
        XCTAssertEqual(FileListSort.sizeDescending.label, "Сначала крупные")
    }

    func testTraditionalChineseSelectionAndRegionalIdentifiers() {
        XCTAssertTrue(AppLanguage.allCases.contains(.zhHant))
        XCTAssertEqual(AppLanguage.zhHant.pickerLabel, "繁體中文")
        XCTAssertEqual(AppLanguage.zhHant.localeIdentifier, "zh-Hant")
        // Traditional: Hant script or Taiwan/Hong Kong/Macau regions.
        for id in ["zh-Hant", "zh-TW", "zh_HK", "zh-Hant-TW", "ZH-Hant", "zh-MO"] {
            XCTAssertEqual(AppLanguage.preferredLanguage(for: id), .zhHant, id)
        }
        // Simplified stays Simplified.
        for id in ["zh", "zh-Hans", "zh-CN", "zh_CN"] {
            XCTAssertEqual(AppLanguage.preferredLanguage(for: id), .zhHans, id)
        }
    }

    func testTraditionalChineseUsesEveryOverloadWithTaiwanVocabulary() {
        AppLanguage.current = .zhHant
        XCTAssertEqual(L10n.tr("智能扫描", "Smart Scan"), "智慧掃描")               // two-arg
        XCTAssertEqual(L10n.tr("优化", "Optimization", "Оптимизация"), "最佳化")     // three-arg
        XCTAssertEqual(L10n.tr("重复文件"), "重複檔案")                              // one-arg
    }

    func testTraditionalChineseFallsBackToSimplifiedWhenUntranslated() {
        AppLanguage.current = .zhHant
        // A key with no Traditional entry returns the Simplified source, which is
        // still readable Chinese, rather than English.
        XCTAssertEqual(L10n.tr("未翻译的新字符串", "Brand new"), "未翻译的新字符串")
        XCTAssertEqual(L10n.tr("未翻译的新字符串"), "未翻译的新字符串")
    }

    func testTraditionalChineseLanguageResourcesCannotBeOfferedForCleanup() {
        for folder in ["zh-Hant.lproj", "zh_TW.lproj", "Traditional Chinese.lproj"] {
            XCTAssertTrue(LanguagePreferences.alwaysKept.contains(folder), folder)
        }
    }


    func testFrenchLanguageSelectionAndRegionalIdentifiers() {
        XCTAssertTrue(AppLanguage.allCases.contains(.fr))
        XCTAssertEqual(AppLanguage.fr.pickerLabel, "Français")
        XCTAssertEqual(AppLanguage.fr.localeIdentifier, "fr")
        for identifier in ["fr", "fr-FR", "fr_CA", "FR-ch"] {
            XCTAssertEqual(AppLanguage.preferredLanguage(for: identifier), .fr)
        }
    }

    func testFrenchUsesEveryTranslationOverload() {
        AppLanguage.current = .fr
        XCTAssertEqual(L10n.tr("设置", "Settings"), "Paramètres")
        XCTAssertEqual(L10n.tr("设置", "Settings", "Настройки"), "Paramètres")
        XCTAssertEqual(L10n.tr("设置"), "Paramètres")
    }

    func testUntranslatedStringFallsBackToEnglishInFrench() {
        AppLanguage.current = .fr
        XCTAssertEqual(L10n.tr("新功能", "New feature"), "New feature")
    }

    func testCleanHistoryIsTranslatedInEveryLanguage() {
        // zhHans key, English, Russian: every static Clean History string.
        let strings: [(String, String, String)] = [
            ("清理历史", "Clean History", "История очистки"),
            ("把最近一次清理整批恢复到原位置。已清空废纸篓或原路径已有文件的项会被跳过。", "Put a whole clean back in one click. Items already emptied from the Trash, or with a new file at their original place, are skipped.", "Верните"),
            ("清除历史", "Clear History", "Очистить историю"),
            ("还没有可恢复的清理记录", "No cleans to restore yet", "Пока нет"),
            ("%ld 项", "%ld items", "%ld элементов"),
            ("部分可恢复", "Partly restorable", "Частично"),
            ("恢复", "Restore", "Восстановить"),
            ("恢复这次清理？", "Restore this clean?", "Восстановить?"),
            ("每一项都会放回原位置。原位置已有的文件绝不会被覆盖。", "Each item goes back to its original place. A file already at that place is never overwritten.", "Каждый"),
            ("这次清理太大，只能恢复前 %ld 项。其余 %ld 项仍在废纸篓中，可在访达里手动放回。", "This clean was too large to track in full: only the first %ld items can be restored. The other %ld are still in the Trash, and you can put them back from Finder.", "Эта"),
            ("恢复完成", "Restore finished", "Готово"),
            ("已恢复：%ld", "Restored: %ld", "Восстановлено: %ld"),
            ("已从废纸篓清空：%ld", "Already emptied from the Trash: %ld", "Уже: %ld"),
            ("原位置已有文件，已跳过：%ld", "Skipped, original place taken: %ld", "Пропущено: %ld"),
            ("无法恢复：%ld", "Couldn't restore: %ld", "Не удалось: %ld"),
            ("清除清理历史？", "Clear clean history?", "Очистить?"),
            ("清除", "Clear", "Очистить"),
            ("这只会忘掉恢复记录，废纸篓里的文件不会被动。之后就不能一键恢复这些清理了。", "This only forgets the restore list. Nothing in the Trash is touched, but these cleans can no longer be restored in one click.", "Это"),
        ]
        for language in [AppLanguage.de, .fr, .it, .ja] {
            AppLanguage.current = language
            for (zh, en, ru) in strings {
                let value = L10n.tr(zh, en, ru)
                XCTAssertNotEqual(value, en, "\(language) is missing: \(en)")
                XCTAssertFalse(value.contains("—"), "no em dashes: \(value)")
                XCTAssertEqual(value.components(separatedBy: "%ld").count, en.components(separatedBy: "%ld").count,
                               "\(language) must keep every %ld placeholder: \(value)")
            }
        }
        AppLanguage.current = .zhHant
        XCTAssertEqual(L10n.tr("恢复这次清理？", "Restore this clean?", "?"), "恢復這次清理？")
        XCTAssertEqual(L10n.tr("清除历史", "Clear History", "?"), "清除歷史")
        XCTAssertEqual(L10n.tr("%ld 项", "%ld items", "?"), "%ld 項")
        for (zh, _, _) in strings {
            let value = L10n.tr(zh, "", "")
            XCTAssertFalse(value.contains("恢复") || value.contains("废纸篓") || value.contains("历史"),
                           "zh-Hant still shows Simplified text: \(value)")
        }
    }

    func testItalianLanguageSelectionAndRegionalIdentifiers() {
        XCTAssertTrue(AppLanguage.allCases.contains(.it))
        XCTAssertEqual(AppLanguage.it.pickerLabel, "Italiano")
        XCTAssertEqual(AppLanguage.it.localeIdentifier, "it")
        for identifier in ["it", "it-IT", "it_IT", "it-CH", "IT-sm"] {
            XCTAssertEqual(AppLanguage.preferredLanguage(for: identifier), .it)
        }
    }

    func testItalianUsesEveryTranslationOverload() {
        AppLanguage.current = .it
        XCTAssertEqual(L10n.tr("设置", "Settings"), "Impostazioni")
        XCTAssertEqual(L10n.tr("设置", "Settings", "Настройки"), "Impostazioni")
        XCTAssertEqual(L10n.tr("设置"), "Impostazioni")
    }

    func testUntranslatedStringFallsBackToEnglishInItalian() {
        AppLanguage.current = .it
        XCTAssertEqual(L10n.tr("新功能", "New feature"), "New feature")
    }

    func testItalianLanguageResourcesCannotBeOfferedForCleanup() {
        for folder in ["it.lproj", "it-IT.lproj", "Italian.lproj"] {
            XCTAssertTrue(LanguagePreferences.alwaysKept.contains(folder), folder)
        }
    }

    func testSupportCardIsTranslatedInEveryLanguage() {
        let expected: [AppLanguage: String] = [
            .de: "Spendier mir einen Kaffee",
            .fr: "Offrez-moi un café",
            .it: "Offrimi un caffè",
            .ja: "コーヒーをおごる",
            .zhHant: "請我喝杯咖啡",
            .ru: "Угостить кофе",
        ]
        for (language, cta) in expected {
            AppLanguage.current = language
            XCTAssertEqual(L10n.tr("请我喝杯咖啡", "Buy me a coffee", "Угостить кофе"), cta)
            let title = L10n.tr("这次清理，你没花一分钱。", "That cleanup cost you nothing.", "Эта очистка не стоила вам ни копейки.")
            XCTAssertNotEqual(title, "That cleanup cost you nothing.", "\(language) title is untranslated")
        }
    }

    func testDiskHogsStringsAreTranslatedInEveryLanguage() {
        AppLanguage.current = .en
        let english = DiskHogsText.all
        AppLanguage.current = .zhHans
        let simplified = DiskHogsText.all
        // Same word in the target language, not a missing translation.
        let sameAsEnglish: Set<String> = ["Images", "Volumes"]
        let sameAsSimplified: Set<String> = [
            "容器", "卷", "大小", "取消", "永久清理", "清理完成", "未能完成", "已停止",
        ]
        for language in [AppLanguage.de, .fr, .it, .ja, .ru] {
            AppLanguage.current = language
            for (index, value) in DiskHogsText.all.enumerated() where !sameAsEnglish.contains(english[index]) || language == .ru {
                XCTAssertNotEqual(value, english[index], "\(language) is missing: \(english[index])")
            }
        }
        AppLanguage.current = .zhHant
        for (index, value) in DiskHogsText.all.enumerated() where !sameAsSimplified.contains(simplified[index]) {
            XCTAssertNotEqual(value, simplified[index], "zh-Hant is missing: \(simplified[index])")
        }
        for language in AppLanguage.allCases {
            AppLanguage.current = language
            XCTAssertFalse(DiskHogsText.all.contains { $0.contains("\u{2014}") }, "\(language) has an em dash")
        }
    }

    /// Every string on the Project Junk screen, as `ProjectJunkView` and
    /// `ScanCategory.projectJunk` pass them to `L10n.tr`.
    func testProjectJunkIsTranslatedInEveryLanguage() {
        let strings: [(zh: String, en: String, ru: String)] = [
            ("项目垃圾", "Project Junk", "Мусор проектов"),
            ("代码项目中的依赖和构建文件夹。", "Dependency and build folders inside your code projects.", "Папки зависимостей и сборки внутри ваших проектов."),
            ("项目中已安装的依赖和构建产物。运行项目的安装或构建命令即可找回；之后第一次构建会更慢。", "Installed dependencies and build output inside your projects. Running the project's install or build command brings them back; the first build afterwards takes longer.", "Установленные зависимости и результаты сборки внутри ваших проектов. Команда установки или сборки проекта вернёт их; первая сборка после этого займёт больше времени."),
            ("选择项目文件夹（例如 ~/Code），查找 node_modules、venv、target、build 等可重建目录。", "Choose a projects folder (e.g. ~/Code) to find regenerable folders like node_modules, venvs, target, and build.", "Выберите папку с проектами (например ~/Code), чтобы найти восстанавливаемые каталоги вроде node_modules, venv, target и build."),
            ("不会自动勾选。", "Nothing is auto-selected.", "Ничего не выбирается заранее."),
            ("未找到项目垃圾", "No project junk found", "Мусор проектов не найден"),
            ("请选择你的项目文件夹，而不是系统文件夹或资源库。", "Choose your projects folder, not a system folder or Library.", "Выберите папку с проектами, а не системную папку или Библиотеку."),
            ("正在查找项目…", "Finding projects…", "Поиск проектов…"),
            ("正在计算文件夹大小…", "Measuring folders…", "Подсчёт размера папок…"),
        ]
        for language in [AppLanguage.de, .fr, .it, .ja, .zhHant, .ru] {
            AppLanguage.current = language
            for s in strings {
                let text = L10n.tr(s.zh, s.en, s.ru)
                XCTAssertNotEqual(text, s.en, "\"\(s.en)\" is untranslated in \(language.rawValue)")
                XCTAssertFalse(text.contains("\u{2014}"), "\"\(s.en)\" has an em dash in \(language.rawValue)")
                if language == .zhHant {
                    // zh-Hant falls back to the Simplified source silently.
                    XCTAssertNotEqual(text, s.zh, "\"\(s.en)\" is untranslated in zh-Hant")
                }
            }
        }
        AppLanguage.current = .en
        for s in strings {
            XCTAssertFalse(L10n.tr(s.zh, s.en, s.ru).contains("\u{2014}"), s.en)
        }
    }

    func testUnusedAppsIsTranslatedInEveryLanguage() {
        // Every user-facing Unused Apps string: (zhHans, English).
        let strings: [(String, String)] = [
            ("未使用的应用", "Unused Apps"),
            ("3 个月", "3 months"),
            ("6 个月", "6 months"),
            ("12 个月", "12 months"),
            ("按上次打开时间列出应用，并按占用空间排序。一键转到卸载器。",
             "Apps you have not opened recently, sorted by how much space they use. One click hands them to the Uninstaller."),
            ("时间", "Horizon"),
            ("刷新", "Refresh"),
            ("正在查找未使用的应用…", "Looking for unused apps…"),
            ("没有符合条件的应用", "No unused apps in this window"),
            ("后台", "Background"),
            ("卸载…", "Uninstall…"),
            ("未知", "Unknown"),
            ("上次打开", "Last opened"),
            ("支持文件", "Support files"),
            ("Spotlight 没有应用的使用记录", "Spotlight has no usage history for your apps"),
            ("无法判断哪些应用未被使用。请检查 Spotlight 索引是否已开启。",
             "Mac Sai can't tell which apps are unused. Check that Spotlight indexing is turned on."),
        ]
        // Written the same in Simplified and Traditional Chinese.
        let sameInTraditional: Set<String> = ["未知"]

        for (zh, english) in strings {
            for language in [AppLanguage.de, .fr, .it, .ja] {
                AppLanguage.current = language
                XCTAssertNotEqual(L10n.tr(zh, english), english, "\(language) is missing \"\(english)\"")
            }
            guard !sameInTraditional.contains(zh) else { continue }
            AppLanguage.current = .zhHant
            XCTAssertNotEqual(L10n.tr(zh, english), zh, "zh-Hant is missing \"\(english)\"")
        }

        AppLanguage.current = .de
        XCTAssertEqual(L10n.tr("后台", "Background"), "Hintergrund")
        AppLanguage.current = .fr
        XCTAssertEqual(L10n.tr("卸载…", "Uninstall…"), "Désinstaller…")
        AppLanguage.current = .zhHant
        XCTAssertEqual(L10n.tr("支持文件", "Support files"), "支援檔案")
    }

    /// Two-line headers must keep a real line break in every language. A
    /// translation that types `\\n` shows the backslash on screen.
    func testMultiLineStringsKeepARealLineBreakInEveryLanguage() {
        let multiLine: [(String, String, String)] = [
            ("扫描 Mac 中的垃圾文件、恶意威胁\n和性能问题",
             "Scan your Mac for junk files, malware threats,\nand performance issues",
             "Поиск на Mac мусора, вредоносных программ\nи проблем с производительностью"),
            ("使用渐进式 SHA-256 哈希检测\n查找重复文件",
             "Find duplicate files using progressive\nSHA-256 hash detection",
             "Поиск дубликатов с помощью поэтапного\nхеширования SHA-256"),
            ("重复文件检测会使用 SHA-256 哈希每个候选文件。\n大型个人目录可能需要 5–15 分钟。",
             "Duplicate detection hashes every candidate file with SHA-256.\nLarge home folders can take 5–15 minutes.",
             "При поиске дубликатов для каждого файла вычисляется хеш SHA-256.\nОбработка больших домашних папок может занять 5–15 минут."),
            ("查找并移除系统缓存、日志、\n语言文件和其他垃圾",
             "Find and remove system caches, logs,\nlanguage files, and other junk",
             "Поиск и удаление системных кэшей, журналов,\nфайлов локализации и другого мусора"),
        ]
        for language in AppLanguage.allCases {
            AppLanguage.current = language
            for (zhHans, english, russian) in multiLine {
                let value = L10n.tr(zhHans, english, russian)
                XCTAssertFalse(value.contains("\\n"), "\(language): literal \\n in \(value)")
                XCTAssertTrue(value.contains("\n"), "\(language): line break lost in \(value)")
            }
        }
    }
}
