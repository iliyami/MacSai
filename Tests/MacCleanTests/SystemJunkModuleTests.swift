import XCTest
import Foundation
@testable import MacClean
import MacCleanKit

final class SystemJunkModuleTests: EnglishAppLanguageTestCase {

    func testRegistersAll21Categories() {
        XCTAssertEqual(SystemJunkModule.allCategories.count, 21)
    }

    func testAllCategoriesAreUnique() {
        let scanCategories = SystemJunkModule.allCategories.map { $0.scanCategory }
        XCTAssertEqual(Set(scanCategories).count, scanCategories.count,
                       "Every category must declare a distinct ScanCategory")
    }

    func testModuleMetadata() {
        let m = SystemJunkModule()
        XCTAssertEqual(m.id, "system_junk")
        XCTAssertEqual(m.name, "System Junk")
        XCTAssertEqual(m.category, .cleanup)
        XCTAssertTrue(m.includedInSmartScan)
    }
    func testSystemJunkRegistersOptInClipboardCategory() {
        let category = SystemJunkModule.allCategories.first { $0.scanCategory == .clipboardArchives }
        XCTAssertTrue(category is ClipboardArchivesCategory)
        XCTAssertFalse(ScanCategory.clipboardArchives.autoSelect)
    }
}
