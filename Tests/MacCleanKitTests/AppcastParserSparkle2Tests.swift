import XCTest
@testable import MacCleanKit

/// Sparkle 2's `generate_appcast` writes the versions as child elements of
/// `<item>` instead of `<enclosure>` attributes. Most real feeds look like this
/// (DockDoor, IINA, Transmission, LaunchOS, KeyClu), and the Updater found no
/// updates at all for them (#189). Fixtures mirror those feeds.
final class AppcastParserSparkle2Tests: XCTestCase {

    func testReadsVersionsWrittenAsItemElements() {
        let xml = """
        <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
          <channel>
            <item>
              <title>1.40.4</title>
              <sparkle:version>1.40.4</sparkle:version>
              <sparkle:shortVersionString>1.40.4</sparkle:shortVersionString>
              <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
              <enclosure url="https://github.com/ejbills/DockDoor/releases/download/1.40.4/DockDoor.dmg"
                         length="22468723" type="application/octet-stream" sparkle:edSignature="sig"/>
            </item>
          </channel>
        </rss>
        """
        let parsed = AppcastParser().parseLatestItem(from: Data(xml.utf8))
        XCTAssertEqual(parsed.version, "1.40.4")
        XCTAssertEqual(
            parsed.downloadURL,
            URL(string: "https://github.com/ejbills/DockDoor/releases/download/1.40.4/DockDoor.dmg")
        )
    }

    /// Element versions can come after the enclosure too; order inside an item
    /// must not matter.
    func testReadsItemElementsThatFollowTheEnclosure() {
        let xml = """
        <rss xmlns:sparkle="ns"><channel><item>
          <enclosure url="https://example.com/App-2.0.dmg" type="application/octet-stream"/>
          <sparkle:shortVersionString>2.0</sparkle:shortVersionString>
        </item></channel></rss>
        """
        let parsed = AppcastParser().parseLatestItem(from: Data(xml.utf8))
        XCTAssertEqual(parsed.version, "2.0")
        XCTAssertEqual(parsed.downloadURL, URL(string: "https://example.com/App-2.0.dmg"))
    }

    /// A marketing version must win over a build number here as well: IINA's
    /// `<sparkle:version>180</sparkle:version>` is not version 180.
    func testPrefersElementMarketingVersionOverBuildNumber() {
        let xml = """
        <rss xmlns:sparkle="ns"><channel><item>
          <sparkle:version>180</sparkle:version>
          <sparkle:shortVersionString>1.5.0</sparkle:shortVersionString>
          <enclosure url="https://dl-portal.iina.io/IINA.v1.5.0.dmg"/>
        </item></channel></rss>
        """
        XCTAssertEqual(AppcastParser().parseLatestItem(from: Data(xml.utf8)).version, "1.5.0")
    }

    /// IINA mixes forms: new items use elements, one old item still uses
    /// attributes. The newest release must win, not the only attribute item.
    func testMixedFeedPicksTheNewestReleaseAcrossBothForms() {
        let xml = """
        <rss xmlns:sparkle="ns"><channel>
          <item>
            <sparkle:version>180</sparkle:version>
            <sparkle:shortVersionString>1.5.0</sparkle:shortVersionString>
            <enclosure url="https://dl-portal.iina.io/IINA.v1.5.0.dmg"/>
          </item>
          <item>
            <enclosure url="https://dl-portal.iina.io/IINA.v1.1.1.dmg"
                       sparkle:version="100" sparkle:shortVersionString="1.1.1"/>
          </item>
        </channel></rss>
        """
        let parsed = AppcastParser().parseLatestItem(from: Data(xml.utf8))
        XCTAssertEqual(parsed.version, "1.5.0")
        XCTAssertEqual(parsed.downloadURL, URL(string: "https://dl-portal.iina.io/IINA.v1.5.0.dmg"))
    }

    /// Delta enclosures patch one specific older build; opening one in the
    /// browser would download a useless `.delta` file.
    func testDownloadURLIgnoresDeltaEnclosures() {
        let xml = """
        <rss xmlns:sparkle="ns"><channel><item>
          <sparkle:shortVersionString>1.5.0</sparkle:shortVersionString>
          <sparkle:deltas>
            <enclosure url="https://dl-portal.iina.io/IINA180-172.delta" sparkle:deltaFrom="172"/>
          </sparkle:deltas>
          <enclosure url="https://dl-portal.iina.io/IINA.v1.5.0.dmg"/>
        </item></channel></rss>
        """
        XCTAssertEqual(
            AppcastParser().parseLatestItem(from: Data(xml.utf8)).downloadURL,
            URL(string: "https://dl-portal.iina.io/IINA.v1.5.0.dmg")
        )
    }

    func testTrimsWhitespaceAroundElementVersions() {
        let xml = """
        <rss xmlns:sparkle="ns"><channel><item>
          <sparkle:shortVersionString>
            4.1.3
          </sparkle:shortVersionString>
          <enclosure url="https://example.com/Transmission-4.1.3.dmg"/>
        </item></channel></rss>
        """
        XCTAssertEqual(AppcastParser().parseLatestItem(from: Data(xml.utf8)).version, "4.1.3")
    }

    /// Element text outside an item (e.g. channel metadata) is never a release.
    func testIgnoresVersionElementsOutsideItems() {
        let xml = """
        <rss xmlns:sparkle="ns"><channel>
          <sparkle:shortVersionString>9.9</sparkle:shortVersionString>
          <item><enclosure url="https://example.com/a.dmg" sparkle:shortVersionString="1.0"/></item>
        </channel></rss>
        """
        XCTAssertEqual(AppcastParser().parseLatestItem(from: Data(xml.utf8)).version, "1.0")
    }

    /// End to end for the reported symptom: installed DockDoor 1.40.1, feed
    /// offers 1.40.4, so an update must be reported.
    func testElementFormFeedReportsANewerVersionThanInstalled() throws {
        let xml = """
        <rss xmlns:sparkle="ns"><channel><item>
          <sparkle:shortVersionString>1.40.4</sparkle:shortVersionString>
          <enclosure url="https://example.com/DockDoor.dmg"/>
        </item></channel></rss>
        """
        let available = try XCTUnwrap(AppcastParser().parseLatestItem(from: Data(xml.utf8)).version)
        XCTAssertTrue(UpdateChecker.isNewer(available, than: "1.40.1"))
    }
}
