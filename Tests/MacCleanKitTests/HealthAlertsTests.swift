import XCTest
@testable import MacCleanKit

final class SwapAlertLatchTests: XCTestCase {
    private let fourGB = HealthAlertSettings.bytes(forGB: 4)

    func testAlertsOnceWhenSwapCrossesTheThreshold() {
        var latch = SwapAlertLatch()
        XCTAssertFalse(latch.shouldAlert(swapUsed: 3_000_000_000, threshold: fourGB))
        XCTAssertTrue(latch.shouldAlert(swapUsed: 4_200_000_000, threshold: fourGB))
        XCTAssertFalse(latch.shouldAlert(swapUsed: 5_000_000_000, threshold: fourGB))
    }

    func testHoveringAroundTheThresholdDoesNotRepeat() {
        var latch = SwapAlertLatch()
        XCTAssertTrue(latch.shouldAlert(swapUsed: 4_100_000_000, threshold: fourGB))
        // Dips just under the line are not "well below" it.
        for used: UInt64 in [3_900_000_000, 4_050_000_000, 3_100_000_000, 4_300_000_000] {
            XCTAssertFalse(latch.shouldAlert(swapUsed: used, threshold: fourGB), "\(used)")
        }
    }

    func testRearmsOnlyAfterDroppingWellBelowTheThreshold() {
        var latch = SwapAlertLatch()
        XCTAssertTrue(latch.shouldAlert(swapUsed: 4_500_000_000, threshold: fourGB))
        XCTAssertFalse(latch.shouldAlert(swapUsed: 2_900_000_000, threshold: fourGB)) // under 75%: re-arms
        XCTAssertNil(latch.firedAtThreshold)
        XCTAssertTrue(latch.shouldAlert(swapUsed: 4_000_000_000, threshold: fourGB))
    }

    func testOffNeverAlertsAndClearsTheLatch() {
        var latch = SwapAlertLatch(firedAtThreshold: fourGB)
        XCTAssertFalse(latch.shouldAlert(swapUsed: 9_000_000_000, threshold: nil))
        XCTAssertNil(latch.firedAtThreshold)
        XCTAssertFalse(latch.shouldAlert(swapUsed: 9_000_000_000, threshold: 0))
    }

    func testChangingTheThresholdRearms() {
        var latch = SwapAlertLatch()
        XCTAssertTrue(latch.shouldAlert(swapUsed: 5_000_000_000, threshold: fourGB))
        // Lowering the threshold under current usage alerts once more.
        XCTAssertTrue(latch.shouldAlert(swapUsed: 5_000_000_000, threshold: HealthAlertSettings.bytes(forGB: 2)))
        // Raising it above current usage stays quiet until swap reaches it.
        XCTAssertFalse(latch.shouldAlert(swapUsed: 5_000_000_000, threshold: HealthAlertSettings.bytes(forGB: 8)))
        XCTAssertTrue(latch.shouldAlert(swapUsed: 8_000_000_000, threshold: HealthAlertSettings.bytes(forGB: 8)))
    }

    func testLatchSurvivesARoundTripThroughStorage() throws {
        let latch = SwapAlertLatch(firedAtThreshold: fourGB)
        let decoded = try JSONDecoder().decode(SwapAlertLatch.self, from: JSONEncoder().encode(latch))
        XCTAssertEqual(decoded, latch)
    }

    func testThresholdChoicesStartWithOffAndUseDecimalGigabytes() {
        XCTAssertEqual(HealthAlertSettings.swapThresholdChoices.first, 0)
        XCTAssertEqual(HealthAlertSettings.bytes(forGB: 2), 2_000_000_000)
        XCTAssertEqual(HealthAlertSettings.bytes(forGB: -1), 0)
    }
}

final class HealthAlertLocalizationTests: AppLanguageTestCase {
    private func allStrings() -> [String] {
        [
            HealthAlertStrings.sectionTitle,
            HealthAlertStrings.memoryPressureToggle,
            HealthAlertStrings.memoryPressureCaption,
            HealthAlertStrings.swapPicker,
            HealthAlertStrings.swapCaption,
            HealthAlertStrings.swapOff,
            HealthAlertStrings.widgetRequired,
            HealthAlertStrings.swapLine(1),
            HealthAlertStrings.swapAlertTitle,
            HealthAlertStrings.swapAlertBody(used: 1, threshold: 2),
        ]
    }

    /// German, French and Italian fall back to English and Traditional
    /// Chinese to Simplified when a key is missing, so each must differ,
    /// except where the right translation is spelled the same.
    func testEveryStringIsTranslatedInEveryLanguage() {
        let swapLine = 7 // "Swap 1 byte" is also German, French and Italian.
        let sameInTraditional: Set = [0, 5] // 提醒, 不提醒
        AppLanguage.current = .en
        let english = allStrings()
        AppLanguage.current = .zhHans
        let simplified = allStrings()
        for language in [AppLanguage.de, .fr, .it] {
            AppLanguage.current = language
            for (index, translated) in allStrings().enumerated() where index != swapLine {
                XCTAssertNotEqual(translated, english[index], "\(language): \(english[index])")
            }
        }
        AppLanguage.current = .zhHant
        for (index, translated) in allStrings().enumerated() where !sameInTraditional.contains(index) {
            XCTAssertNotEqual(translated, simplified[index], "zh-Hant: \(simplified[index])")
        }
    }

    func testPlaceholdersAreFilledInEveryLanguage() {
        for language in [AppLanguage.en, .de, .fr, .it, .ru, .zhHans, .zhHant] {
            AppLanguage.current = language
            let body = HealthAlertStrings.swapAlertBody(used: 6_800_000_000, threshold: 4_000_000_000)
            XCTAssertFalse(body.contains("{"), "\(language): \(body)")
            XCTAssertTrue(body.contains(FileSizeFormatter.format(UInt64(6_800_000_000))), "\(language)")
            XCTAssertTrue(body.contains(FileSizeFormatter.format(UInt64(4_000_000_000))), "\(language)")
            XCTAssertFalse(HealthAlertStrings.swapLine(1).contains("{"), "\(language)")
        }
    }
}
