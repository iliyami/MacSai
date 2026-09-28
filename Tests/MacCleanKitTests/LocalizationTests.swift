import XCTest

@testable import MacCleanKit

final class LocalizationTests: AppLanguageTestCase {
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
}
