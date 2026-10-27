#!/usr/bin/env swift
// Release-only verification against the public key embedded by build-dmg.sh.
// This helper never reads the signing secret. Sparkle separately verifies the
// feed using the same signing key source used by generate_appcast.
import CryptoKit
import Foundation

enum VerificationFailure: Error, CustomStringConvertible {
    case invalid(String)
    var description: String {
        switch self { case .invalid(let message): return message }
    }
}

func require(_ condition: Bool, _ message: String) throws {
    guard condition else { throw VerificationFailure.invalid(message) }
}

func secureURL(_ value: String) -> URL? {
    guard let url = URL(string: value), url.scheme == "https",
          let host = url.host, !host.isEmpty,
          url.user == nil, url.password == nil, url.fragment == nil else { return nil }
    return url
}

do {
    let args = CommandLine.arguments
    try require(args.count == 5, "Expected feed, archive directory, public key and HTTPS download prefix")
    guard let keyData = Data(base64Encoded: args[3]), keyData.count == 32 else {
        throw VerificationFailure.invalid("Configured public key must decode to exactly 32 bytes")
    }
    let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: keyData)
    guard let prefix = secureURL(args[4]), prefix.query == nil else {
        throw VerificationFailure.invalid("Download prefix must be HTTPS without credentials, query or fragment")
    }
    let archiveDirectory = URL(fileURLWithPath: args[2], isDirectory: true).resolvingSymlinksInPath()
    let xml = try XMLDocument(contentsOf: URL(fileURLWithPath: args[1]), options: .nodeLoadExternalEntitiesNever)
    let items = try xml.nodes(forXPath: "/rss/channel/item")
    try require(!items.isEmpty, "Generated feed contains no update items")
    let signatureNamespace = "http://www.andymatuschak.org/xml-namespaces/sparkle"
    for item in items {
        let enclosures = try item.nodes(forXPath: "enclosure")
        try require(enclosures.count == 1, "Each update must contain exactly one archive enclosure")
        guard let enclosure = enclosures[0] as? XMLElement,
              let source = enclosure.attribute(forName: "url")?.stringValue,
              let remoteURL = secureURL(source) else {
            throw VerificationFailure.invalid("Archive URL must use HTTPS without credentials or a fragment")
        }
        let name = remoteURL.lastPathComponent
        try require(!name.isEmpty && name != "." && name != ".." && !name.contains("/"), "Invalid archive filename")
        try require(["dmg", "zip"].contains(remoteURL.pathExtension.lowercased()), "Unsupported archive extension")
        let expectedURL = prefix.appendingPathComponent(name)
        try require(remoteURL == expectedURL, "Archive URL does not match the configured download prefix")
        let archiveURL = archiveDirectory.appendingPathComponent(name).resolvingSymlinksInPath()
        try require(archiveURL.deletingLastPathComponent() == archiveDirectory, "Archive is outside the release directory")
        let resource = try archiveURL.resourceValues(forKeys: [.isRegularFileKey])
        try require(resource.isRegularFile == true, "Archive is not a regular file")
        let archive = try Data(contentsOf: archiveURL, options: .mappedIfSafe)
        guard let lengthText = enclosure.attribute(forName: "length")?.stringValue,
              let length = UInt64(lengthText), length > 0, length == UInt64(archive.count) else {
            throw VerificationFailure.invalid("Archive length must be positive and match the file exactly")
        }
        guard let encodedSignature = enclosure.attribute(forLocalName: "edSignature", uri: signatureNamespace)?.stringValue,
              let signature = Data(base64Encoded: encodedSignature), signature.count == 64 else {
            throw VerificationFailure.invalid("Every archive needs a valid base64 Ed25519 signature of exactly 64 bytes")
        }
        try require(publicKey.isValidSignature(signature, for: archive), "Archive signature does not match the configured public key or archive bytes")
    }
} catch {
    FileHandle.standardError.write(Data("ERROR: update feed verification failed: \(error)\n".utf8))
    exit(1)
}
