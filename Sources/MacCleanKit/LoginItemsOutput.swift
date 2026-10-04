import Foundation

/// One login item as reported by System Events.
public struct ParsedLoginItem: Equatable, Sendable {
    public let name: String
    public let path: String?
    public let hidden: Bool

    public init(name: String, path: String?, hidden: Bool) {
        self.name = name
        self.path = path
        self.hidden = hidden
    }
}

/// Parses `osascript` output for a list of `{name:…, path:…, hidden:…}`
/// records. osascript prints the whole list on a single line, e.g.
///   name:A, path:/Applications/A.app, hidden:false, name:B, path:/…, hidden:true
/// so records are split where a new `name` key starts, not per line.
public enum LoginItemsOutput {
    public static func parse(_ output: String) -> [ParsedLoginItem] {
        var items: [ParsedLoginItem] = []
        var name: String?
        var path: String?
        var hidden = false

        func flush() {
            if let name, !name.isEmpty {
                items.append(ParsedLoginItem(name: name, path: path, hidden: hidden))
            }
            name = nil
            path = nil
            hidden = false
        }

        for line in output.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            for pair in trimmed.components(separatedBy: ", ") {
                let kv = pair.split(separator: ":", maxSplits: 1).map(String.init)
                guard kv.count == 2 else { continue }
                let key = kv[0].trimmingCharacters(in: .whitespaces)
                let val = kv[1].trimmingCharacters(in: .whitespaces)
                switch key {
                case "name":
                    flush()
                    name = val
                case "path": path = val
                case "hidden": hidden = (val.lowercased() == "true")
                default: break
                }
            }
        }
        flush()
        return items
    }
}
