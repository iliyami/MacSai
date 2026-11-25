import Foundation
import XCTest

@testable import MacCleanKit

final class MenuBarMetricTests: XCTestCase {
    func testCasesAndRawValuesStayStable() {
        XCTAssertEqual(
            MenuBarMetric.allCases.map(\.rawValue),
            ["diskFree", "gpuUsage", "memoryUsage", "temperature", "networkSpeed", "iconOnly"]
        )
    }

    func testMissingAndUnknownValuesFallBackToDisk() {
        XCTAssertEqual(MenuBarMetric.resolve(nil), .diskFree)
        XCTAssertEqual(MenuBarMetric.resolve("futureMetric"), .diskFree)
        XCTAssertEqual(MenuBarMetric.resolve("temperature"), .batteryTemperature)
        XCTAssertEqual(MenuBarMetric.resolve("iconOnly"), .iconOnly)
        XCTAssertEqual(MenuBarMetric.resolve("networkSpeed"), .networkSpeed)
    }

    /// #182: a cleaner menu bar with just the app's sparkles icon, no value.
    func testIconOnlyShowsNoValueWhateverTheStats() {
        XCTAssertNil(MenuBarMetric.iconOnly.formattedValue(
            diskFree: 245_000_000_000,
            gpuUsage: 0.5,
            memoryUsage: 0.5,
            batteryTemperature: 30
        ))
    }

    func testEveryValueMetricStillProducesText() {
        for metric in MenuBarMetric.allCases where metric != .iconOnly {
            XCTAssertNotNil(
                metric.formattedValue(diskFree: 0, gpuUsage: nil, memoryUsage: 0, batteryTemperature: nil),
                metric.rawValue
            )
        }
    }

    func testIconOnlyNameIsTranslatedInEveryLanguage() {
        let sharedDefaults = SharedAppState.defaults
        let sharedValue = sharedDefaults.object(forKey: AppLanguage.defaultsKey)
        let standardValue = UserDefaults.standard.object(forKey: AppLanguage.defaultsKey)
        defer {
            if let sharedValue {
                sharedDefaults.set(sharedValue, forKey: AppLanguage.defaultsKey)
            } else {
                sharedDefaults.removeObject(forKey: AppLanguage.defaultsKey)
            }
            if let standardValue {
                UserDefaults.standard.set(standardValue, forKey: AppLanguage.defaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: AppLanguage.defaultsKey)
            }
        }

        let expected: [AppLanguage: String] = [
            .en: "Icon only",
            .zhHans: "仅显示图标",
            .zhHant: "僅顯示圖示",
            .ru: "Только значок",
            .de: "Nur Symbol",
        ]
        for (language, name) in expected {
            AppLanguage.current = language
            XCTAssertEqual(MenuBarMetric.iconOnly.localizedName, name, language.rawValue)
        }
    }

    func testLocalizedNames() {
        let sharedDefaults = SharedAppState.defaults
        let sharedValue = sharedDefaults.object(forKey: AppLanguage.defaultsKey)
        let standardValue = UserDefaults.standard.object(forKey: AppLanguage.defaultsKey)
        defer {
            if let sharedValue {
                sharedDefaults.set(sharedValue, forKey: AppLanguage.defaultsKey)
            } else {
                sharedDefaults.removeObject(forKey: AppLanguage.defaultsKey)
            }
            if let standardValue {
                UserDefaults.standard.set(standardValue, forKey: AppLanguage.defaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: AppLanguage.defaultsKey)
            }
        }

        AppLanguage.current = .en
        XCTAssertEqual(MenuBarMetric.diskFree.localizedName, "Free disk space")
        XCTAssertEqual(MenuBarMetric.gpuUsage.localizedName, "GPU usage")
        XCTAssertEqual(MenuBarMetric.memoryUsage.localizedName, "Memory usage")
        XCTAssertEqual(MenuBarMetric.batteryTemperature.localizedName, "Battery temperature")

        AppLanguage.current = .zhHans
        XCTAssertEqual(MenuBarMetric.diskFree.localizedName, "可用磁盘空间")
        XCTAssertEqual(MenuBarMetric.batteryTemperature.localizedName, "电池温度")
    }

    /// #262: the network option is named in every shipped language.
    func testNetworkSpeedNameIsTranslatedInEveryLanguage() {
        let sharedDefaults = SharedAppState.defaults
        let sharedValue = sharedDefaults.object(forKey: AppLanguage.defaultsKey)
        defer {
            if let sharedValue {
                sharedDefaults.set(sharedValue, forKey: AppLanguage.defaultsKey)
            } else {
                sharedDefaults.removeObject(forKey: AppLanguage.defaultsKey)
            }
        }

        let expected: [AppLanguage: String] = [
            .en: "Network speed",
            .zhHans: "网络速度",
            .zhHant: "網路速度",
            .ru: "Скорость сети",
            .de: "Netzwerkgeschwindigkeit",
            .fr: "Vitesse du réseau",
            .es: "Velocidad de red",
            .it: "Velocità di rete",
            .ptBR: "Velocidade da rede",
            .ja: "ネットワーク速度",
            .ko: "네트워크 속도",
            .tr: "Ağ hızı",
            .fa: "سرعت شبکه",
        ]
        for (language, name) in expected {
            AppLanguage.current = language
            XCTAssertEqual(MenuBarMetric.networkSpeed.localizedName, name, language.rawValue)
        }
    }

    /// #262: download and upload side by side, e.g. "↓ 12.5 MB/s ↑ 2.3 MB/s".
    func testNetworkSpeedShowsDownloadAndUpload() {
        XCTAssertEqual(
            MenuBarMetric.networkSpeed.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: nil,
                downloadBytesPerSecond: 12_500_000,
                uploadBytesPerSecond: 2_300_000
            ),
            "↓ 12.5 MB/s ↑  2.3 MB/s"
        )
        XCTAssertEqual(
            MenuBarMetric.networkSpeed.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: nil
            ),
            "↓        -- ↑        --"
        )
    }

    /// The label is drawn in a monospaced font, so a constant character count
    /// keeps the menu bar item from changing width (and shifting every icon to
    /// its left) each time the speed updates.
    func testNetworkSpeedKeepsAConstantWidth() {
        let samples: [(Double?, Double?)] = [
            (nil, nil), (0, 0), (999, 5), (45_000, 1_200), (12_500_000, 99_900_000),
        ]
        let widths = Set(samples.map { download, upload in
            MenuBarMetric.networkSpeed.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: nil,
                downloadBytesPerSecond: download,
                uploadBytesPerSecond: upload
            )?.count
        })
        XCTAssertEqual(widths, [23])
    }

    func testDiskKeepsExistingFormatting() {
        let bytes: UInt64 = 245_000_000_000
        XCTAssertEqual(
            MenuBarMetric.diskFree.formattedValue(
                diskFree: bytes,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: nil
            ),
            FileSizeFormatter.format(bytes)
        )
    }

    func testPercentagesRoundAndClamp() {
        XCTAssertEqual(
            MenuBarMetric.gpuUsage.formattedValue(
                diskFree: 0,
                gpuUsage: 0.424,
                memoryUsage: 0,
                batteryTemperature: nil
            ),
            "GPU 42%"
        )
        XCTAssertEqual(
            MenuBarMetric.gpuUsage.formattedValue(
                diskFree: 0,
                gpuUsage: -0.2,
                memoryUsage: 0,
                batteryTemperature: nil
            ),
            "GPU 0%"
        )
        XCTAssertEqual(
            MenuBarMetric.memoryUsage.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 1.2,
                batteryTemperature: nil
            ),
            "RAM 100%"
        )
    }

    func testUnavailableAndNonFiniteValuesUseDoubleHyphen() {
        XCTAssertEqual(
            MenuBarMetric.gpuUsage.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: nil
            ),
            "GPU --"
        )
        XCTAssertEqual(
            MenuBarMetric.memoryUsage.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: .nan,
                batteryTemperature: nil
            ),
            "RAM --"
        )
        XCTAssertEqual(
            MenuBarMetric.batteryTemperature.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: nil
            ),
            "--"
        )
        XCTAssertEqual(
            MenuBarMetric.batteryTemperature.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: .infinity
            ),
            "--"
        )
    }

    func testBatteryTemperatureRoundsToWholeDegrees() {
        XCTAssertEqual(
            MenuBarMetric.batteryTemperature.formattedValue(
                diskFree: 0,
                gpuUsage: nil,
                memoryUsage: 0,
                batteryTemperature: 30.6
            ),
            "31°C"
        )
    }
}
