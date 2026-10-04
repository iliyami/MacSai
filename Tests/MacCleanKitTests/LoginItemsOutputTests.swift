import XCTest
@testable import MacCleanKit

final class LoginItemsOutputTests: XCTestCase {

    func testParsesEveryRecordFromOsascriptsSingleLineList() {
        // osascript prints a list of records on ONE line, comma-separated.
        let output = "name:Dropbox, path:/Applications/Dropbox.app, hidden:false, "
            + "name:Rectangle, path:/Applications/Rectangle.app, hidden:true\n"
        XCTAssertEqual(LoginItemsOutput.parse(output), [
            ParsedLoginItem(name: "Dropbox", path: "/Applications/Dropbox.app", hidden: false),
            ParsedLoginItem(name: "Rectangle", path: "/Applications/Rectangle.app", hidden: true),
        ])
    }

    func testParsesASingleRecord() {
        XCTAssertEqual(
            LoginItemsOutput.parse("name:Dropbox, path:/Applications/Dropbox.app, hidden:false"),
            [ParsedLoginItem(name: "Dropbox", path: "/Applications/Dropbox.app", hidden: false)]
        )
    }

    func testRecordWithoutPathIsKept() {
        XCTAssertEqual(
            LoginItemsOutput.parse("name:Helper, hidden:false, name:Other, path:/Applications/Other.app, hidden:false"),
            [
                ParsedLoginItem(name: "Helper", path: nil, hidden: false),
                ParsedLoginItem(name: "Other", path: "/Applications/Other.app", hidden: false),
            ]
        )
    }

    func testEmptyOutputYieldsNoItems() {
        XCTAssertEqual(LoginItemsOutput.parse(""), [])
        XCTAssertEqual(LoginItemsOutput.parse("\n"), [])
    }
}
