import Foundation
import XCTest

@testable import MacCleanKit

final class HardwareSensorNormalizerTests: XCTestCase {
    func testBatteryReaderKeepsLegacySourceAndDoesNotQueryPackUnnecessarily() {
        var loadedClasses: [String] = []
        let temperature = HardwareSensorNormalizer.readBatteryTemperature { serviceClass in
            loadedClasses.append(serviceClass)
            return [["Temperature": 3_125]]
        }

        XCTAssertEqual(temperature, 31.25)
        XCTAssertEqual(loadedClasses, ["AppleSmartBattery"])
    }

    func testBatteryReaderFindsMacOS27PackTemperatureInMixedBatteryData() {
        var loadedClasses: [String] = []
        let temperature = HardwareSensorNormalizer.readBatteryTemperature { serviceClass in
            loadedClasses.append(serviceClass)
            if serviceClass == "AppleSmartBattery" {
                // macOS 27's root record retains capacities but no temperature.
                return [["BatteryData": ["CurrentCapacity": 80, "MaxCapacity": 100]]]
            }
            return [["BatteryData": [
                "Temperature": 3_019,
                "VirtualTemperature": 3_019,
                "Serial": "fixture-only",
                "LifetimeData": ["AverageTemperature": 252, "MaximumTemperature": 41],
            ]]]
        }

        XCTAssertEqual(temperature, 30.19)
        XCTAssertEqual(loadedClasses, ["AppleSmartBattery", "AppleSmartBatteryPack"])
    }

    func testBatteryReaderUsesHundredthsForColdPackWithoutGuessingScale() {
        let temperature = HardwareSensorNormalizer.readBatteryTemperature { serviceClass in
            serviceClass == "AppleSmartBatteryPack"
                ? [["BatteryData": ["Temperature": 800]]]
                : []
        }

        XCTAssertEqual(temperature, 8)
    }

    func testBatteryReaderSkipsInvalidEntriesAndUsesVirtualTemperature() {
        let temperature = HardwareSensorNormalizer.readBatteryTemperature { serviceClass in
            guard serviceClass == "AppleSmartBatteryPack" else {
                return [["Temperature": 0]]
            }
            return [
                ["BatteryData": "malformed"],
                ["BatteryData": ["Temperature": Double.infinity]],
                ["BatteryData": ["Temperature": 0, "VirtualTemperature": 2_950]],
            ]
        }

        XCTAssertEqual(temperature, 29.5)
    }

    func testBatteryReaderNeverSubstitutesHistoricalOrNonBatteryTemperatures() {
        let temperature = HardwareSensorNormalizer.readBatteryTemperature { _ in
            [["CPUTemperature": 45, "BatteryData": [
                "Temperature": 12_100,
                "VirtualTemperature": -1,
                "LifetimeData": ["AverageTemperature": 252, "MaximumTemperature": 41],
            ]]]
        }

        XCTAssertNil(temperature)
        XCTAssertNil(HardwareSensorNormalizer.readBatteryTemperature { _ in [] })
    }

    func testGPUUsageChoosesMaximumAcrossKnownKeysAndSamples() throws {
        let samples: [[String: NSNumber]] = [
            ["Device Utilization %": 24],
            ["GPU Activity(%)": 67, "Renderer Utilization %": 82],
        ]

        let usage = try XCTUnwrap(HardwareSensorNormalizer.gpuUsageFraction(from: samples))

        XCTAssertEqual(usage, 0.82, accuracy: 0.0001)
    }

    func testGPUUsageClampsFiniteValues() {
        XCTAssertEqual(
            HardwareSensorNormalizer.gpuUsageFraction(
                from: [["Device Utilization %": -15]]
            ),
            0
        )
        XCTAssertEqual(
            HardwareSensorNormalizer.gpuUsageFraction(
                from: [["Device Utilization %": 140]]
            ),
            1
        )
    }

    func testGPUUsageIgnoresUnknownAndNonFiniteValues() {
        XCTAssertNil(
            HardwareSensorNormalizer.gpuUsageFraction(
                from: [
                    ["Unknown": 50],
                    ["GPU Activity(%)": NSNumber(value: Double.nan)],
                ]
            )
        )
    }

    func testBatteryTemperatureNormalizesSupportedEncodings() throws {
        let hundredths = try XCTUnwrap(HardwareSensorNormalizer.batteryTemperatureCelsius(
            fromRawValue: 3_092
        ))
        let tenths = try XCTUnwrap(
            HardwareSensorNormalizer.batteryTemperatureCelsius(fromRawValue: 306)
        )
        let coldTenths = try XCTUnwrap(
            HardwareSensorNormalizer.batteryTemperatureCelsius(fromRawValue: 150)
        )
        let degrees = try XCTUnwrap(
            HardwareSensorNormalizer.batteryTemperatureCelsius(fromRawValue: 30.5)
        )

        XCTAssertEqual(hundredths, 30.92, accuracy: 0.0001)
        XCTAssertEqual(tenths, 30.6, accuracy: 0.0001)
        XCTAssertEqual(coldTenths, 15, accuracy: 0.0001)
        XCTAssertEqual(degrees, 30.5, accuracy: 0.0001)
    }

    func testBatteryTemperatureRejectsInvalidReadings() {
        XCTAssertNil(
            HardwareSensorNormalizer.batteryTemperatureCelsius(fromRawValue: 0)
        )
        XCTAssertNil(
            HardwareSensorNormalizer.batteryTemperatureCelsius(fromRawValue: 12_100)
        )
        XCTAssertNil(
            HardwareSensorNormalizer.batteryTemperatureCelsius(
                fromRawValue: NSNumber(value: Double.infinity)
            )
        )
    }

    func testBatteryTemperatureFallsBackToNextRegistryKey() throws {
        let temperature = try XCTUnwrap(HardwareSensorNormalizer.batteryTemperatureCelsius(
            from: [
                "Temperature": 0,
                "VirtualTemperature": 3_125,
            ]
        ))

        XCTAssertEqual(temperature, 31.25, accuracy: 0.0001)
    }
}
