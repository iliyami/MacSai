import Foundation
import XCTest

@testable import MacCleanKit

final class FanControlPolicyTests: XCTestCase {
    private typealias Write = FanControlPolicy.Write

    private func flt(_ value: Double) -> FanSpeedReader.SMCValue {
        ("flt ", FanSpeedReader.encode(value, type: "flt ") ?? [])
    }

    private func fpe2(_ value: Double) -> FanSpeedReader.SMCValue {
        ("fpe2", FanSpeedReader.encode(value, type: "fpe2") ?? [])
    }

    /// One Apple Silicon fan in automatic mode.
    private func appleSilicon(mode: UInt8 = 0, test: UInt8 = 0) -> [String: FanSpeedReader.SMCValue] {
        [
            "FNum": ("ui8 ", [1]),
            "F0Ac": flt(1500), "F0Mn": flt(1200), "F0Mx": flt(6000), "F0Tg": flt(1500),
            "F0Md": ("ui8 ", [mode]),
            "Ftst": ("ui8 ", [test]),
        ]
    }

    func testOnlyFanModeTargetAndUnlockKeysAreWritable() {
        for key in ["F0Md", "F0Tg", "F7Md", "F3Tg", "Ftst", "FS! "] {
            XCTAssertTrue(FanControlPolicy.isWritableKey(key), key)
        }
        for key in ["FNum", "F0Ac", "F0Mn", "F0Mx", "F8Md", "FxMd", "F0Md ", "TC0P", "CLKS", "", "Ftst2"] {
            XCTAssertFalse(FanControlPolicy.isWritableKey(key), key)
        }
    }

    func testClampKeepsTargetsInsideTheRatedRange() {
        XCTAssertEqual(FanControlPolicy.clamp(rpm: 500, minimum: 1200, maximum: 6000), 1200)
        XCTAssertEqual(FanControlPolicy.clamp(rpm: 9000, minimum: 1200, maximum: 6000), 6000)
        XCTAssertEqual(FanControlPolicy.clamp(rpm: 3000, minimum: 1200, maximum: 6000), 3000)
        XCTAssertNil(FanControlPolicy.clamp(rpm: .nan, minimum: 1200, maximum: 6000))
        XCTAssertNil(FanControlPolicy.clamp(rpm: .infinity, minimum: 1200, maximum: 6000))
        XCTAssertNil(FanControlPolicy.clamp(rpm: 3000, minimum: nil, maximum: 6000))
        XCTAssertNil(FanControlPolicy.clamp(rpm: 3000, minimum: 1200, maximum: 0))
        XCTAssertNil(FanControlPolicy.clamp(rpm: 3000, minimum: 7000, maximum: 6000))
    }

    func testSliderFractionMapsOntoRange() {
        let fan = FanSpeed(index: 0, current: 1500, minimum: 1000, maximum: 6000)
        XCTAssertEqual(FanControlPolicy.rpm(atFraction: 0, for: fan), 1000)
        XCTAssertEqual(FanControlPolicy.rpm(atFraction: 0.5, for: fan), 3500)
        XCTAssertEqual(FanControlPolicy.rpm(atFraction: 2, for: fan), 6000)
        XCTAssertNil(FanControlPolicy.rpm(atFraction: .nan, for: fan))
        XCTAssertNil(FanControlPolicy.rpm(atFraction: 0.5, for: FanSpeed(index: 0, current: 0, minimum: nil, maximum: nil)))
    }

    func testAppleSiliconManualPinsModeThenClampedTarget() throws {
        let keys = appleSilicon()
        let plan = try FanControlPolicy.manualWrites(fan: 0, rpm: 9000) { keys[$0] }.get()

        XCTAssertEqual(plan.target, 6000)
        XCTAssertEqual(plan.writes, [
            Write(key: "F0Md", bytes: [1]),
            Write(key: "F0Tg", bytes: flt(6000).bytes),
        ])
        XCTAssertTrue(plan.writes.allSatisfy { FanControlPolicy.isWritableKey($0.key) })
    }

    func testLegacyIntelManualSetsForcedBitAndFixedPointTarget() throws {
        let keys: [String: FanSpeedReader.SMCValue] = [
            "FNum": ("ui8 ", [2]),
            "F1Mn": fpe2(1000), "F1Mx": fpe2(6000), "F1Tg": fpe2(1000),
            "FS! ": ("ui16", [0x00, 0x01]),
        ]
        let plan = try FanControlPolicy.manualWrites(fan: 1, rpm: 2500) { keys[$0] }.get()

        XCTAssertEqual(plan.writes, [
            Write(key: "FS! ", bytes: [0x00, 0x03]),
            Write(key: "F1Tg", bytes: [0x27, 0x10]),
        ])
    }

    func testManualRefusesBadRequests() {
        let keys = appleSilicon()
        XCTAssertEqual(FanControlPolicy.manualWrites(fan: 1, rpm: 3000) { keys[$0] }.failure, .noSuchFan)
        XCTAssertEqual(FanControlPolicy.manualWrites(fan: -1, rpm: 3000) { keys[$0] }.failure, .noSuchFan)
        XCTAssertEqual(FanControlPolicy.manualWrites(fan: 0, rpm: .nan) { keys[$0] }.failure, .invalidSpeed)
        XCTAssertEqual(FanControlPolicy.manualWrites(fan: 0, rpm: 3000) { _ in nil }.failure, .noSuchFan)

        var noRange = keys
        noRange["F0Mx"] = nil
        XCTAssertEqual(FanControlPolicy.manualWrites(fan: 0, rpm: 3000) { noRange[$0] }.failure, .missingRange)

        var noTarget = keys
        noTarget["F0Tg"] = nil
        XCTAssertEqual(FanControlPolicy.manualWrites(fan: 0, rpm: 3000) { noTarget[$0] }.failure, .unsupported)
    }

    func testNeverOverridesThermalManagement() {
        let keys = appleSilicon(mode: 3)
        XCTAssertEqual(FanControlPolicy.manualWrites(fan: 0, rpm: 3000) { keys[$0] }.failure, .thermalManaged)
        XCTAssertEqual(FanControlPolicy.automaticWrites { keys[$0] }, [])
    }

    func testAutomaticIsANoOpWhenAlreadyAutomatic() {
        let keys = appleSilicon()
        XCTAssertEqual(FanControlPolicy.automaticWrites { keys[$0] }, [])
        XCTAssertEqual(FanControlPolicy.automaticWrites { _ in nil }, [])
    }

    func testAutomaticResetsModeForcedMaskAndTestUnlock() {
        var keys = appleSilicon(mode: 1, test: 1)
        keys["FS! "] = ("ui16", [0x00, 0x01])

        XCTAssertEqual(FanControlPolicy.automaticWrites { keys[$0] }, [
            Write(key: "F0Md", bytes: [0]),
            Write(key: "FS! ", bytes: [0x00, 0x00]),
            Write(key: "Ftst", bytes: [0]),
        ])
    }

    func testUnlockOnlyWhenTestKeyExistsAndIsClear() {
        XCTAssertEqual(FanControlPolicy.unlockWrites { self.appleSilicon()[$0] }, [Write(key: "Ftst", bytes: [1])])
        XCTAssertEqual(FanControlPolicy.unlockWrites { self.appleSilicon(test: 1)[$0] }, [])
        XCTAssertEqual(FanControlPolicy.unlockWrites { _ in nil }, [])
    }
}

private extension Result {
    var failure: Failure? {
        if case .failure(let error) = self { return error }
        return nil
    }
}

final class FanStringsLocalizationTests: AppLanguageTestCase {
    /// Every new fan string must have a real translation, not the English fallback.
    func testFanStringsAreTranslatedInEveryLanguage() {
        let keys = [
            "风扇", "转/分", "风扇控制（高级）",
            "安装一个需在系统设置中批准的辅助程序。Mac Sai 退出、Mac 睡眠或辅助程序断开连接时，风扇会恢复自动。",
            "在系统设置中批准", "此版本无法使用风扇控制。", "自动", "手动", "风扇控制失败，已恢复自动。",
        ]
        for language in [AppLanguage.de, .fr, .it, .zhHant] {
            AppLanguage.current = language
            for key in keys {
                let value = L10n.tr(key, "untranslated")
                XCTAssertNotEqual(value, "untranslated", "\(language.rawValue): \(key)")
                XCTAssertFalse(value.contains("—"), "\(language.rawValue): \(key)")
            }
        }
        AppLanguage.current = .de
        XCTAssertEqual(L10n.tr("自动", "Automatic", "Автоматически"), "Automatisch")
    }
}
