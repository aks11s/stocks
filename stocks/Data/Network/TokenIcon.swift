import Foundation

// icons come from the CoinCap CDN, keyed by the lowercased ticker (btc, eth, ...)
enum TokenIcon {

    private static let base = "https://assets.coincap.io/assets/icons"

    static func url(for ticker: String) -> URL? {
        let clean = ticker
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
        guard !clean.isEmpty else { return nil }
        return URL(string: "\(base)/\(clean)@2x.png")
    }
}
