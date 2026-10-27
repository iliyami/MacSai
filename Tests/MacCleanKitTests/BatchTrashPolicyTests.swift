import Foundation
import XCTest
@testable import MacCleanKit

final class BatchTrashPolicyTests: XCTestCase {
    private let source = URL(filePath: "/Users/test/Library/Caches/a")
    private let other = URL(filePath: "/Users/test/Library/Caches/b")
    private let trash = "/Users/test/.Trash"

    func testPartialReceiptPreservesSuccessAndDoesNotInferOtherSuccess() {
        let target = URL(filePath: trash + "/a")
        let outcomes = BatchTrashPolicy.outcomes(requested: [source, other], relocated: [source: target],
                                                missing: [], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes[source], .moved(to: target))
        XCTAssertEqual(outcomes[other], .failed)
    }

    func testMissingOnlyAppliesWhenNoMoveWasReported() {
        let target = URL(filePath: trash + "/a")
        let outcomes = BatchTrashPolicy.outcomes(requested: [source, other], relocated: [source: target],
                                                missing: [source, other], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes[source], .moved(to: target))
        XCTAssertEqual(outcomes[other], .missing)
    }

    func testUnrequestedReceiptCannotAddRemovedItems() {
        let target = URL(filePath: trash + "/b")
        let outcomes = BatchTrashPolicy.outcomes(requested: [source], relocated: [other: target],
                                                missing: [], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes, [source: .failed])
    }

    func testRepeatedRequestIsCountedOnce() {
        let target = URL(filePath: trash + "/a")
        let outcomes = BatchTrashPolicy.outcomes(requested: [source, source], relocated: [source: target],
                                                missing: [], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes.count, 1)
    }

    func testDuplicateDestinationsAreNotRestorableReceipts() {
        let target = URL(filePath: trash + "/a")
        let outcomes = BatchTrashPolicy.outcomes(requested: [source, other], relocated: [source: target, other: target],
                                                missing: [], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes[source], .invalidReceipt)
        XCTAssertEqual(outcomes[other], .invalidReceipt)
    }

    func testRejectsOutsideTrashTraversalNonFileAndIdentityDestination() {
        for target in [URL(filePath: "/System/test"), URL(filePath: trash),
                       URL(filePath: trash + "/../Documents/a"), URL(string: "https://example.com/a")!, source,
                       URL(filePath: "/Volumes/External/.Trashes/502/a"),
                       URL(string: "file://example.com/Users/test/.Trash/a")!] {
            let outcomes = BatchTrashPolicy.outcomes(requested: [source], relocated: [source: target],
                                                    missing: [], trashRoot: trash, uid: 501)
            XCTAssertEqual(outcomes[source], .invalidReceipt, target.absoluteString)
        }
    }

    func testAcceptsCurrentUsersExternalVolumeTrash() {
        let target = URL(filePath: "/Volumes/External/.Trashes/501/a")
        let outcomes = BatchTrashPolicy.outcomes(requested: [source], relocated: [source: target],
                                                missing: [], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes[source], .moved(to: target))
    }

    func testDirectoryReceiptIsNormalizedForRestoreAcrossFoundationVersions() {
        let target = URL(filePath: trash + "/folder", directoryHint: .isDirectory)
        let outcomes = BatchTrashPolicy.outcomes(requested: [source], relocated: [source: target],
                                                missing: [], trashRoot: trash, uid: 501)
        let restorable = URL(filePath: trash + "/folder", directoryHint: .notDirectory)
        XCTAssertEqual(outcomes[source], .moved(to: restorable))
        if case .moved(let destination) = outcomes[source] {
            XCTAssertFalse(destination.path(percentEncoded: false).hasSuffix("/"))
            XCTAssertTrue(CleanHistoryRestore.isInsideTrash(destination.path(percentEncoded: false),
                                                           trashRoot: trash, uid: 501))
        }
    }

    func testDirectoryMarkerCannotHideDuplicateDestinations() {
        let target = URL(filePath: trash + "/folder", directoryHint: .notDirectory)
        let directoryTarget = URL(filePath: trash + "/folder", directoryHint: .isDirectory)
        let outcomes = BatchTrashPolicy.outcomes(requested: [source, other],
                                                relocated: [source: target, other: directoryTarget],
                                                missing: [], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes[source], .invalidReceipt)
        XCTAssertEqual(outcomes[other], .invalidReceipt)
    }

    func testDirectoryMarkerCannotHideIdentityDestination() {
        let source = URL(filePath: trash + "/folder", directoryHint: .notDirectory)
        let target = URL(filePath: trash + "/folder", directoryHint: .isDirectory)
        let outcomes = BatchTrashPolicy.outcomes(requested: [source], relocated: [source: target],
                                                missing: [], trashRoot: trash, uid: 501)
        XCTAssertEqual(outcomes[source], .invalidReceipt)
    }
}
