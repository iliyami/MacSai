import Foundation

/// A build can offer installation only with an explicit HTTPS feed and an
/// embedded Ed25519 public key. The private key never belongs in the app.
public struct SelfUpdateConfiguration: Equatable, Sendable {
    public let feedURL: URL
    public let publicKey: String

    public init?(infoDictionary: [String: Any]) {
        guard let feed = infoDictionary["SUFeedURL"] as? String,
              let url = URL(string: feed),
              url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil, url.fragment == nil,
              let key = infoDictionary["SUPublicEDKey"] as? String,
              let decoded = Data(base64Encoded: key), decoded.count == 32,
              infoDictionary["SUVerifyUpdateBeforeExtraction"] as? Bool == true,
              infoDictionary["SURequireSignedFeed"] as? Bool == true,
              infoDictionary["SUSignedFeedFailureExpirationInterval"] as? Int == 0
        else { return nil }
        feedURL = url
        publicKey = key
    }
}
