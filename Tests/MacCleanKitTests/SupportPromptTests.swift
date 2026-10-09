import XCTest
@testable import MacCleanKit

final class SupportPromptTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!
    private let gb: UInt64 = 1_000_000_000
    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    override func setUp() {
        super.setUp()
        suiteName = "SupportPromptTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func clean(_ bytes: UInt64, at date: Date) -> Bool {
        SupportPrompt.registerClean(freedBytes: bytes, now: date, defaults: defaults)
    }

    // MARK: - Pure policy

    func testNeverAsksOnTheVeryFirstClean() {
        let state = SupportPrompt.State(cleanCount: 1, lastShown: nil, optedOut: false)
        XCTAssertFalse(SupportPrompt.shouldShow(state: state, freedBytes: 50 * gb, now: start))
    }

    func testAsksAfterABigCleanOnceTrustIsEstablished() {
        let state = SupportPrompt.State(cleanCount: 2, lastShown: nil, optedOut: false)
        XCTAssertTrue(SupportPrompt.shouldShow(state: state, freedBytes: 1 * gb, now: start))
    }

    func testSmallCleansNeverAsk() {
        let state = SupportPrompt.State(cleanCount: 9, lastShown: nil, optedOut: false)
        XCTAssertFalse(SupportPrompt.shouldShow(state: state, freedBytes: gb - 1, now: start))
    }

    func testOptOutIsPermanent() {
        let state = SupportPrompt.State(cleanCount: 50, lastShown: nil, optedOut: true)
        XCTAssertFalse(SupportPrompt.shouldShow(state: state, freedBytes: 100 * gb, now: start))
    }

    func testCooldownHoldsForSixtyDays() {
        let state = SupportPrompt.State(cleanCount: 5, lastShown: start, optedOut: false)
        let justBefore = start.addingTimeInterval(SupportPrompt.cooldown - 1)
        let after = start.addingTimeInterval(SupportPrompt.cooldown)
        XCTAssertFalse(SupportPrompt.shouldShow(state: state, freedBytes: 10 * gb, now: justBefore))
        XCTAssertTrue(SupportPrompt.shouldShow(state: state, freedBytes: 10 * gb, now: after))
        XCTAssertEqual(SupportPrompt.cooldown, 60 * 24 * 60 * 60)
    }

    // MARK: - Persistence

    func testRegisterCleanCountsEveryCleanAndRecordsTheAsk() {
        XCTAssertFalse(clean(20 * gb, at: start), "first clean is never asked")
        XCTAssertTrue(clean(2 * gb, at: start.addingTimeInterval(60)))
        XCTAssertFalse(clean(30 * gb, at: start.addingTimeInterval(120)), "cooldown starts when shown")
        XCTAssertEqual(SupportPrompt.state(defaults: defaults).cleanCount, 3)
    }

    func testSmallCleansStillCountTowardTrust() {
        XCTAssertFalse(clean(10, at: start))
        XCTAssertTrue(clean(5 * gb, at: start))
    }

    func testOptingOutStopsFutureAsks() {
        XCTAssertFalse(clean(0, at: start))
        SupportPrompt.optOut(defaults: defaults)
        XCTAssertFalse(clean(80 * gb, at: start.addingTimeInterval(365 * 86_400)))
    }

    func testSupportURLIsTheCoffeePage() {
        XCTAssertEqual(MCConstants.supportURL.absoluteString, "https://buymeacoffee.com/iliyami")
    }
}
