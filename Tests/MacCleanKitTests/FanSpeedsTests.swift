import Foundation
import XCTest

@testable import MacCleanKit

final class FanSpeedsTests: XCTestCase {
    // 1500 and 6000 rpm as Apple Silicon little-endian floats.
    private let flt1500: [UInt8] = [0x00, 0x80, 0xBB, 0x44]
    private let flt6000: [UInt8] = [0x00, 0x80, 0xBB, 0x45]

    func testDecodesIntelFixedPointAndAppleSiliconFloat() {
        // fpe2: 0x1770 / 4 = 1500.
        XCTAssertEqual(FanSpeedReader.decode(("fpe2", [0x17, 0x70])), 1500)
        XCTAssertEqual(FanSpeedReader.decode(("fpe2", [0x00, 0x03])), 0.75)
        XCTAssertEqual(FanSpeedReader.decode(("flt ", flt1500)), 1500)
        XCTAssertEqual(FanSpeedReader.decode(("ui8 ", [2])), 2)
        XCTAssertEqual(FanSpeedReader.decode(("ui16", [0x01, 0x02])), 258)
    }

    func testRejectsUnknownTypesAndShortPayloads() {
        XCTAssertNil(FanSpeedReader.decode(("sp78", [0x20, 0x00])))
        XCTAssertNil(FanSpeedReader.decode(("flt ", [0x00, 0x80])))
        XCTAssertNil(FanSpeedReader.decode(("fpe2", [0x17])))
        XCTAssertNil(FanSpeedReader.decode(("ui8 ", [])))
    }

    func testEncodeRoundTripsEveryWrittenType() {
        for type in ["fpe2", "flt ", "ui8 ", "ui16"] {
            let bytes = FanSpeedReader.encode(200, type: type)
            XCTAssertEqual(bytes.flatMap { FanSpeedReader.decode((type, $0)) }, 200, type)
        }
        XCTAssertEqual(FanSpeedReader.encode(1500, type: "flt "), flt1500)
        XCTAssertEqual(FanSpeedReader.encode(1500, type: "fpe2"), [0x17, 0x70])
        XCTAssertNil(FanSpeedReader.encode(.nan, type: "flt "))
        XCTAssertNil(FanSpeedReader.encode(-1, type: "ui8 "))
        XCTAssertNil(FanSpeedReader.encode(256, type: "ui8 "))
        XCTAssertNil(FanSpeedReader.encode(1, type: "sp78"))
    }

    func testFourCharCodesArePackedBigEndian() {
        XCTAssertEqual(FanSpeedReader.fourCharCode("FNum"), 0x464E_756D)
        XCTAssertEqual(FanSpeedReader.string(fromFourCharCode: 0x666C_7420), "flt ")
    }

    func testFanlessMacsAndMissingSMCReportNoFans() {
        XCTAssertEqual(FanSpeedReader.readFans { _ in nil }, [])
        XCTAssertEqual(FanSpeedReader.readFans { $0 == "FNum" ? ("ui8 ", [0]) : nil }, [])
        // A count with no speed keys behind it is not a fan either.
        XCTAssertEqual(FanSpeedReader.readFans { $0 == "FNum" ? ("ui8 ", [2]) : nil }, [])
    }

    func testReadsAppleSiliconFans() {
        let keys: [String: FanSpeedReader.SMCValue] = [
            "FNum": ("ui8 ", [2]),
            "F0Ac": ("flt ", flt1500), "F0Mn": ("flt ", flt1500), "F0Mx": ("flt ", flt6000),
            // Second fan reports a speed but no range.
            "F1Ac": ("flt ", [0, 0, 0, 0]),
        ]
        let fans = FanSpeedReader.readFans { keys[$0] }

        XCTAssertEqual(fans, [
            FanSpeed(index: 0, current: 1500, minimum: 1500, maximum: 6000),
            FanSpeed(index: 1, current: 0, minimum: nil, maximum: nil),
        ])
    }

    func testReadsIntelFansAndDropsImplausibleSpeeds() {
        let keys: [String: FanSpeedReader.SMCValue] = [
            "FNum": ("ui8 ", [2]),
            "F0Ac": ("fpe2", [0x17, 0x70]), "F0Mn": ("fpe2", [0x0F, 0xA0]), "F0Mx": ("fpe2", [0x5D, 0xC0]),
            "F1Ac": ("flt ", [0x00, 0x00, 0xC0, 0x7F]), // NaN
        ]
        let fans = FanSpeedReader.readFans { keys[$0] }

        XCTAssertEqual(fans, [FanSpeed(index: 0, current: 1500, minimum: 1000, maximum: 6000)])
    }

    func testCapsGarbageFanCount() {
        var requested: Set<String> = []
        _ = FanSpeedReader.readFans { key in
            requested.insert(key)
            return key == "FNum" ? ("ui8 ", [200]) : ("flt ", self.flt1500)
        }
        XCTAssertTrue(requested.contains("F7Ac"))
        XCTAssertFalse(requested.contains("F8Ac"))
    }

    func testFractionPlacesCurrentSpeedWithinRange() {
        XCTAssertEqual(FanSpeed(index: 0, current: 3500, minimum: 1000, maximum: 6000).fraction, 0.5)
        XCTAssertEqual(FanSpeed(index: 0, current: 500, minimum: 1000, maximum: 6000).fraction, 0)
        XCTAssertEqual(FanSpeed(index: 0, current: 9000, minimum: 1000, maximum: 6000).fraction, 1)
        XCTAssertEqual(FanSpeed(index: 0, current: 0, minimum: nil, maximum: nil).fraction, 0)
    }
}
