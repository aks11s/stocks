import Foundation

// Resolves a token's icon URL from its base ticker.
// Source: CoinCap CDN — icons keyed by lowercased ticker (btc, eth, …).
// Swap the base here to change providers app-wide.
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
