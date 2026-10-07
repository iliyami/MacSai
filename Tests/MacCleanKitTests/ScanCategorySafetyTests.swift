import XCTest
import Foundation

@testable import MacCleanKit

/// The review screen explains *why* each category is safe to clean (#180).
/// These pin that every category has an honest rationale, and that only the
/// genuinely rebuildable ones are allowed to say they come back on their own.
final class ScanCategorySafetyTests: AppLanguageTestCase {

    func testGenuinelyRebuildableCategoriesSayTheyRegenerate() {
        let rebuildable: [ScanCategory] = [
            .userCaches, .systemCaches, .packageManagerCaches, .ideCaches, .aiToolCaches,
        ]
        for category in rebuildable {
            XCTAssertEqual(category.cleanupSafety, .regenerates, category.rawValue)
        }
    }

    /// Anything only reversible by re-downloading, or that holds the user's own
    /// data, must keep cautious wording.
    func testIrreversibleOrPersonalCategoriesAskForReview() {
        let cautious: [ScanCategory] = [
            .universalBinaries, .deletedUsers, .languageFiles, .iosDeviceBackups,
            .documentVersions, .unusedDiskImages, .xcodeJunk, .trashBins,
            .mailAttachments, .browserPrivacy, .systemPrivacy,
            .largeFiles, .oldFiles, .duplicates,
        ]
        for category in cautious {
            XCTAssertEqual(category.cleanupSafety, .reviewFirst, category.rawValue)
        }
    }

    /// Xcode Junk is exempt: it names which of its parts rebuild and which don't.
    func testNoCategoryOutsideRegeneratesClaimsToRebuildItself() {
        AppLanguage.current = .en
        let claims = ["regenerat", "recreated", "rebuilt", "rebuilds"]
        for category in ScanCategory.allCases
        where category.cleanupSafety != .regenerates && category != .xcodeJunk {
            let text = category.safetyRationale.lowercased()
            for claim in claims {
                XCTAssertFalse(
                    text.contains(claim),
                    "\(category.rawValue) is not rebuildable but its rationale says \"\(claim)\""
                )
            }
        }
    }

    func testUserCachesRationaleMatchesTheIssueWording() {
        AppLanguage.current = .en
        XCTAssertEqual(
            ScanCategory.userCaches.safetyRationale,
            "App temp files. Recreated automatically the next time each app launches."
        )
    }

    /// Xcode Junk mixes rebuildable DerivedData with Archives, which cannot be
    /// regenerated. The rationale must say so instead of calling it all cache.
    func testXcodeJunkWarnsThatArchivesCannotBeRegenerated() {
        AppLanguage.current = .en
        let text = ScanCategory.xcodeJunk.safetyRationale
        XCTAssertTrue(text.contains("DerivedData"))
        XCTAssertTrue(text.contains("Archives"))
    }

    /// Trash Bins is the one category deleted permanently rather than moved to
    /// the Trash, so its rationale must not imply it can be recovered.
    func testTrashBinsRationaleSaysItCannotBeUndone() {
        AppLanguage.current = .en
        XCTAssertTrue(ScanCategory.trashBins.safetyRationale.contains("can't be undone"))
    }

    func testEveryCategoryHasADistinctRationaleBeyondItsSubtitle() {
        AppLanguage.current = .en
        let rationales = ScanCategory.allCases.map(\.safetyRationale)
        XCTAssertEqual(Set(rationales).count, rationales.count)
        for category in ScanCategory.allCases {
            XCTAssertNotEqual(category.safetyRationale, category.subtitle, category.rawValue)
        }
    }

    func testRationaleAndLabelAreNeverBlankInAnyLanguage() {
        for language in AppLanguage.allCases {
            AppLanguage.current = language
            for category in ScanCategory.allCases {
                XCTAssertFalse(
                    category.safetyRationale.trimmingCharacters(in: .whitespaces).isEmpty,
                    "\(category.rawValue)/\(language.rawValue)"
                )
                XCTAssertFalse(category.cleanupSafety.label.isEmpty, language.rawValue)
            }
        }
    }

    func testRationaleIsTranslatedForEverySupportedLanguage() {
        AppLanguage.current = .en
        let english = ScanCategory.allCases.map(\.safetyRationale)
        let englishLabels = ScanCategory.CleanupSafety.allCases.map(\.label)
        for language in [AppLanguage.ru, .de, .zhHans, .zhHant] {
            AppLanguage.current = language
            for (category, englishText) in zip(ScanCategory.allCases, english) {
                XCTAssertNotEqual(
                    category.safetyRationale, englishText,
                    "\(category.rawValue) rationale is untranslated in \(language.rawValue)"
                )
            }
            for (safety, englishLabel) in zip(ScanCategory.CleanupSafety.allCases, englishLabels) {
                XCTAssertNotEqual(safety.label, englishLabel, "\(safety) label in \(language.rawValue)")
            }
        }
    }

    /// Traditional Chinese silently falls back to Simplified when a key is
    /// missing, so the English comparison above can't catch a gap there.
    func testEveryRationaleHasATraditionalChineseTranslation() {
        AppLanguage.current = .zhHans
        let simplified = ScanCategory.allCases.map(\.safetyRationale)
        AppLanguage.current = .zhHant
        for (category, simplifiedText) in zip(ScanCategory.allCases, simplified) {
            XCTAssertNotEqual(category.safetyRationale, simplifiedText, category.rawValue)
        }
    }
}
