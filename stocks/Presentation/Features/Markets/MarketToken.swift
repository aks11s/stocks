import Foundation

struct MarketToken {
    let symbol: String        // BTCUSDT
    let baseAsset: String     // BTC
    let name: String          // Bitcoin
    let logoName: String      // asset catalog name

    var price: String
    var change: String
    var isUptrend: Bool
    var chartPoints: [Double] // close prices from klines
}

// MARK: - Static metadata

extension MarketToken {

    // Maps Binance symbol → display name + logo asset
    static let metadata: [String: (name: String, base: String, logo: String)] = [
        "BTCUSDT":  ("Bitcoin",  "BTC",  "logo_btc"),
        "ETHUSDT":  ("Ethereum", "ETH",  "logo_eth"),
        "SOLUSDT":  ("Solana",   "SOL",  "logo_sol"),
        "ADAUSDT":  ("Cardano",  "ADA",  "logo_ada"),
        "SHIBUSDT": ("SHIBA INU","SHIB", "logo_shib"),
        "TONUSDT":  ("Toncoin",  "TON",  "logo_ton"),
    ]

    var pair: String { "\(baseAsset)/USDT" }

    // Build a token from a REST ticker + sparkline points
    static func from(symbol: String, price: String, changePercent: String, klines: [Double]) -> MarketToken? {
        guard let meta = metadata[symbol] else { return nil }
        let pct = Double(changePercent) ?? 0
        let formatted = String(format: pct >= 0 ? "+%.2f%%" : "%.2f%%", pct)
        return MarketToken(
            symbol: symbol,
            baseAsset: meta.base,
            name: meta.name,
            logoName: meta.logo,
            price: formatPrice(price),
            change: formatted,
            isUptrend: pct >= 0,
            chartPoints: klines
        )
    }

    // Applies live miniTicker update in place
    mutating func applyTicker(close: String, open: String) {
        let c = Double(close) ?? 0
        let o = Double(open)  ?? 0
        price = Self.formatPrice(close)
        let pct = o != 0 ? (c - o) / o * 100 : 0
        change = String(format: pct >= 0 ? "+%.2f%%" : "%.2f%%", pct)
        isUptrend = pct >= 0
    }

    private static func formatPrice(_ raw: String) -> String {
        guard let v = Double(raw) else { return raw }
        if v >= 1000 { return String(format: "%.2f", v) }
        if v >= 1    { return String(format: "%.4f", v) }
        return String(format: "%.8f", v)
            .replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
    }
}
