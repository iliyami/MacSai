import XCTest
@testable import MacCleanKit

final class PnpmStoreTests: AppLanguageTestCase {
    func testVersionNumberParsesOnlyStoreVersionFolders() {
        XCTAssertEqual(PnpmStore.versionNumber(ofFolderNamed: "v3"), 3)
        XCTAssertEqual(PnpmStore.versionNumber(ofFolderNamed: "v10"), 10)
        for name in ["v", "v0", "10", "V10", "v10.lock", "v+5", "v-1", "tmp", "v١٠", ""] {
            XCTAssertNil(PnpmStore.versionNumber(ofFolderNamed: name), name)
        }
    }

    func testNewestVersionAcrossRootsIsCurrentAndTheRestAreStale() {
        let library = URL(filePath: "/Users/me/Library/pnpm/store")
        let legacy = URL(filePath: "/Users/me/.pnpm-store")
        let versions = PnpmStore.versions(in: [
            library.appending(path: "v3"),
            library.appending(path: "v10"),
            library.appending(path: "tmp"),
            legacy.appending(path: "v3"),
        ])
        XCTAssertEqual(versions.map(\.number), [10, 3, 3])
        XCTAssertEqual(versions.map(\.isCurrent), [true, false, false])
        XCTAssertTrue(PnpmStore.versions(in: [library.appending(path: "tmp")]).isEmpty)
    }

    func testStoreRootsNeverIncludePnpmHome() {
        // ~/Library/pnpm also holds the pnpm binary and global packages.
        let roots = MCConstants.pnpmStoreRoots.map { $0.path(percentEncoded: false) }
        XCTAssertTrue(roots.contains { $0.hasSuffix("/Library/pnpm/store") })
        XCTAssertTrue(roots.contains { $0.hasSuffix("/.local/share/pnpm/store") })
        XCTAssertTrue(roots.contains { $0.hasSuffix("/.pnpm-store") })
        XCTAssertFalse(roots.contains { $0.hasSuffix("/Library/pnpm") || $0.hasSuffix("/Library/pnpm/") })
        XCTAssertEqual(PackageManagerCachesCategory().pnpmStoreRoots, MCConstants.pnpmStoreRoots)
    }

    func testNotesAreTranslatedInEveryLanguage() {
        func notes() -> [String] { [PnpmStore.staleNote, PnpmStore.currentNote] }
        AppLanguage.current = .en
        let english = notes()
        AppLanguage.current = .zhHans
        let simplified = notes()
        for language in [AppLanguage.de, .fr, .it, .ru] {
            AppLanguage.current = language
            for (value, source) in zip(notes(), english) {
                XCTAssertNotEqual(value, source, "\(language) is missing: \(source)")
            }
        }
        AppLanguage.current = .zhHant
        XCTAssertNotEqual(notes(), simplified)
    }
}
