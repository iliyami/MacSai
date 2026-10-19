import XCTest
import MacCleanKit
@testable import MacClean

/// Every user-facing string on the Browser Extensions screen must be
/// translated in German, French, Traditional Chinese, and Russian, and none
/// may use an em dash.
final class BrowserExtensionsLocalizationTests: EnglishAppLanguageTestCase {
    private func sampleRecord(_ origin: BrowserExtensionOrigin) -> BrowserExtensionRecord {
        BrowserExtensionRecord(
            browser: origin == .safariApp ? .safari : .chrome,
            profile: "Default",
            identifier: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            name: "Sample",
            updatedAt: nil,
            path: "/x/Default/Extensions/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            origin: origin,
            isSuspicious: false
        )
    }

    /// Simplified-only characters that appear in these strings. If the
    /// zh-Hans source contains one, the zh-Hant result must differ from it.
    private let simplifiedOnly = Set("扩读设软应这认识运无装关开览为将删请态网标从")

    private func allStrings() -> [String] {
        var strings = [
            BrowserExtensionsStrings.subtitle,
            BrowserExtensionsStrings.reading,
            BrowserExtensionsStrings.empty,
            BrowserExtensionsStrings.safariUnavailable,
            BrowserExtensionsStrings.suspicious,
            BrowserExtensionsStrings.suspiciousHelp,
            BrowserExtensionsStrings.policyTag,
            BrowserExtensionsStrings.builtInTag,
            BrowserExtensionsStrings.unknownDate,
            BrowserExtensionsStrings.details,
            BrowserExtensionsStrings.confirmTitle(for: sampleRecord(.user)),
            BrowserExtensionsStrings.confirmTitle(for: sampleRecord(.policy)),
            L10n.tr("在设置中打开", "Open in Settings", "Открыть в настройках"),
        ]
        for origin in [BrowserExtensionOrigin.user, .policy, .component, .safariApp] {
            strings.append(BrowserExtensionsStrings.confirmMessage(for: sampleRecord(origin)))
        }
        let outcomes: [BrowserExtensionsClient.RemovalOutcome] = [
            .trashed, .removeInBrowser(.chrome), .removeInBrowser(.firefox), .removeInBrowser(.brave),
            .managedByPolicy(.edge), .builtIn(.chrome), .refused, .failed("x"),
        ]
        strings.append(contentsOf: outcomes.compactMap(BrowserExtensionsStrings.message(for:)))
        return strings
    }

    func testEveryStringIsTranslatedInEveryLanguage() {
        AppLanguage.current = .en
        let english = allStrings()
        AppLanguage.current = .zhHans
        let simplified = allStrings()

        for language in [AppLanguage.de, .fr, .it, .tr, .ru] {
            AppLanguage.current = language
            for (index, value) in allStrings().enumerated() {
                XCTAssertNotEqual(value, english[index], "\(language) is untranslated: \(english[index])")
            }
        }

        AppLanguage.current = .zhHant
        for (index, value) in allStrings().enumerated() where !simplifiedOnly.isDisjoint(with: simplified[index]) {
            XCTAssertNotEqual(value, simplified[index], "zh-Hant is untranslated: \(english[index])")
        }
    }

    func testNoEmDashesOrUnfilledPlaceholders() {
        for language in [AppLanguage.en, .de, .fr, .it, .tr, .ru, .zhHans, .zhHant] {
            AppLanguage.current = language
            for value in allStrings() {
                XCTAssertFalse(value.contains("\u{2014}"), "\(language) has an em dash: \(value)")
                XCTAssertFalse(value.contains("{browser}") || value.contains("{url}"), "\(language) unfilled: \(value)")
            }
        }
    }

    func testRunningMessagesSayWhereToRemove() {
        AppLanguage.current = .en
        XCTAssertTrue(BrowserExtensionsStrings.removeInBrowserText(.chrome).contains("Window > Extensions"))
        XCTAssertTrue(BrowserExtensionsStrings.removeInBrowserText(.firefox).contains("Tools > Add-ons and Themes"))
        XCTAssertTrue(BrowserExtensionsStrings.removeInBrowserText(.edge).contains("edge://extensions"))
        XCTAssertTrue(BrowserExtensionsStrings.confirmMessage(for: sampleRecord(.user)).contains("sync"))
    }
}
