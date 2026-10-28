import XCTest
@testable import MacCleanKit

final class CleanupLocalizationTests: AppLanguageTestCase {
    private let staticKeys = [
        "全选", "取消全选", "选择安全项目", "已处理",
        "选择所有允许自动勾选的项目。需要手动检查的类别和可能的威胁保持不选。",
        "仅保留安全的临时文件、缓存、日志和残留文件。不选择个人数据、废纸篓或应用修改。",
        "请至少勾选一个要清理的项目", "清理所选项目",
        "选中的文件会移到废纸篓，如有需要仍可恢复。",
        "废纸篓中选中的项目将永久删除，无法恢复。",
        "应用中未使用的架构将被移除。恢复可能需要重新安装应用。",
    ]

    func testStaticCleanupCopyIsTranslatedForEveryDictionaryBackedLanguage() {
        for language in [AppLanguage.de, .fr, .it, .zhHant] {
            AppLanguage.current = language
            for key in staticKeys {
                let value = L10n.tr(key, "UNTRANSLATED", "Russian")
                XCTAssertNotEqual(value, "UNTRANSLATED", "Missing \(language) translation: \(key)")
                XCTAssertNotEqual(value, key, "Simplified Chinese leaked into \(language): \(key)")
                XCTAssertFalse(value.isEmpty)
            }
        }
    }

    func testDynamicCleanupCopyIsTranslatedForAllLanguages() {
        AppLanguage.current = .en
        let english = [CleanupStrings.selectionSummary(selected: 2, total: 21),
                       CleanupStrings.confirmationTitle(count: 2), CleanupStrings.itemCount(2)]
        for language in [AppLanguage.de, .fr, .it, .ru, .zhHans, .zhHant] {
            AppLanguage.current = language
            let localized = [CleanupStrings.selectionSummary(selected: 2, total: 21),
                             CleanupStrings.confirmationTitle(count: 2), CleanupStrings.itemCount(2)]
            for (index, value) in localized.enumerated() {
                XCTAssertNotEqual(value, english[index], "Missing dynamic translation in \(language)")
                XCTAssertTrue(value.contains("2"))
            }
        }
    }

    func testRussianCountsUseCorrectNounCaseInSummaryAndConfirmation() {
        AppLanguage.current = .ru
        for (count, summaryNoun, itemNoun) in [
            (1, "объекта", "объект"), (2, "объектов", "объекта"),
            (5, "объектов", "объектов"), (11, "объектов", "объектов"),
            (21, "объекта", "объект"), (22, "объектов", "объекта"),
        ] {
            XCTAssertEqual(CleanupStrings.selectionSummary(selected: 1, total: count),
                           "Выбрано 1 из \(count) \(summaryNoun)")
            XCTAssertEqual(CleanupStrings.confirmationTitle(count: count), "Очистить \(count) \(itemNoun)?")
            XCTAssertEqual(CleanupStrings.itemCount(count), "\(count) \(itemNoun)")
        }
    }

    func testEnglishConfirmationAndResultCountHaveSingularForms() {
        AppLanguage.current = .en
        XCTAssertEqual(CleanupStrings.selectionSummary(selected: 1, total: 1), "1 of 1 item selected")
        XCTAssertEqual(CleanupStrings.confirmationTitle(count: 1), "Clean 1 item?")
        XCTAssertEqual(CleanupStrings.confirmationTitle(count: 2), "Clean 2 items?")
        XCTAssertEqual(CleanupStrings.itemCount(1), "1 item")
        XCTAssertEqual(CleanupStrings.itemCount(2), "2 items")
    }
}
