import XCTest
@testable import MacCleanKit

final class SupportersListTests: XCTestCase {
    private var supportersPage: String {
        get throws {
            let repoRoot = URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            return try String(contentsOf: repoRoot.appending(path: "SUPPORTERS.md"), encoding: .utf8)
        }
    }

    /// The app and SUPPORTERS.md must thank the same people.
    func testEveryNameInTheAppIsOnTheSupportersPage() throws {
        let page = try supportersPage
        for name in Supporters.names {
            XCTAssertTrue(page.contains(name), "\(name) is in the app but not in SUPPORTERS.md")
        }
    }

    func testNamesAreUniqueAndTrimmed() {
        XCTAssertEqual(Set(Supporters.names).count, Supporters.names.count)
        for name in Supporters.names {
            XCTAssertFalse(name.isEmpty)
            XCTAssertEqual(name, name.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    func testMembershipPageIsOnBuyMeACoffee() {
        XCTAssertEqual(MCConstants.membershipURL.absoluteString, "https://buymeacoffee.com/iliyami/membership")
    }
}

final class SupporterStringsTests: AppLanguageTestCase {
    func testCaptionListsEveryName() {
        AppLanguage.current = .en
        let caption = SupporterStrings.caption(for: ["Ada", "Grace"])
        XCTAssertTrue(caption.contains("Ada, Grace"), caption)
        XCTAssertFalse(caption.contains("{"), caption)
    }

    func testCaptionInvitesTheFirstMemberWhenNobodyIsListed() {
        AppLanguage.current = .en
        XCTAssertEqual(SupporterStrings.caption(for: []), SupporterStrings.emptyCaption)
    }

    private func allStrings() -> [String] {
        [
            SupporterStrings.title,
            SupporterStrings.caption(for: ["Ada"]),
            SupporterStrings.emptyCaption,
            SupporterStrings.supportCaption,
        ]
    }

    /// German, French and Italian fall back to English and Traditional
    /// Chinese to Simplified when a key is missing, so each must differ,
    /// except where the right translation is spelled the same.
    func testEveryStringIsTranslatedInEveryLanguage() {
        let sameInTraditional: Set = [0] // 支持者
        AppLanguage.current = .en
        let english = allStrings()
        AppLanguage.current = .zhHans
        let simplified = allStrings()
        for language in [AppLanguage.de, .fr, .it, .ru, .ptBR, .es] {
            AppLanguage.current = language
            for (index, translated) in allStrings().enumerated() {
                XCTAssertNotEqual(translated, english[index], "\(language): \(english[index])")
            }
        }
        AppLanguage.current = .zhHant
        for (index, translated) in allStrings().enumerated() where !sameInTraditional.contains(index) {
            XCTAssertNotEqual(translated, simplified[index], "zh-Hant: \(simplified[index])")
        }
    }

    func testPlaceholderIsFilledInEveryLanguage() {
        for language in [AppLanguage.en, .de, .fr, .it, .ru, .zhHans, .zhHant, .ptBR, .es] {
            AppLanguage.current = language
            let caption = SupporterStrings.caption(for: ["Ada"])
            XCTAssertTrue(caption.contains("Ada"), "\(language): \(caption)")
            XCTAssertFalse(caption.contains("{"), "\(language): \(caption)")
        }
    }
}
