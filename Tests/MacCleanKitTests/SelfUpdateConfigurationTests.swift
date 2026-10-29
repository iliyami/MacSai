import XCTest
@testable import MacCleanKit

final class SelfUpdateConfigurationTests: XCTestCase {
    private var valid: [String: Any] {
        ["SUFeedURL": "https://updates.example.org/appcast.xml",
         "SUPublicEDKey": Data(repeating: 42, count: 32).base64EncodedString(),
         "SUVerifyUpdateBeforeExtraction": true,
         "SURequireSignedFeed": true,
         "SUSignedFeedFailureExpirationInterval": 0]
    }

    func testAcceptsExplicitSignedHTTPSConfiguration() {
        XCTAssertEqual(SelfUpdateConfiguration(infoDictionary: valid)?.feedURL.host, "updates.example.org")
    }

    func testRejectsIncompleteOrUnsignedConfiguration() {
        for key in valid.keys {
            var configuration = valid
            configuration.removeValue(forKey: key)
            XCTAssertNil(SelfUpdateConfiguration(infoDictionary: configuration), key)
        }
        for key in ["SUVerifyUpdateBeforeExtraction", "SURequireSignedFeed"] {
            var configuration = valid
            configuration[key] = false
            XCTAssertNil(SelfUpdateConfiguration(infoDictionary: configuration))
        }
    }

    func testSignedFeedRequirementCannotExpire() {
        var configuration = valid
        configuration["SUSignedFeedFailureExpirationInterval"] = 1_728_000
        XCTAssertNil(SelfUpdateConfiguration(infoDictionary: configuration))
    }

    func testRejectsUnsafeFeedsAndInvalidKeys() {
        for feed in ["http://updates.example.org/appcast.xml", "file:///tmp/feed.xml", "https:///", "https://user:password@example.org/feed", "https://example.org/feed#fragment"] {
            var configuration = valid
            configuration["SUFeedURL"] = feed
            XCTAssertNil(SelfUpdateConfiguration(infoDictionary: configuration), feed)
        }
        for key in ["", "not a key", Data(repeating: 1, count: 31).base64EncodedString()] {
            var configuration = valid
            configuration["SUPublicEDKey"] = key
            XCTAssertNil(SelfUpdateConfiguration(infoDictionary: configuration))
        }
    }
}
