import Foundation

struct TickerDTO: Decodable {
    let symbol: String
    let lastPrice: String
    let priceChange: String
    let priceChangePercent: String
    let highPrice: String
    let lowPrice: String
    let volume: String
    let bestBid: String
    let bestAsk: String

    private enum CodingKeys: String, CodingKey {
        case instId  = "instId"
        case last    = "last"
        case open24h = "open24h"
        case high24h = "high24h"
        case low24h  = "low24h"
        case vol24h  = "vol24h"
        case bidPx   = "bidPx"
        case askPx   = "askPx"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        symbol    = try c.decode(String.self, forKey: .instId)
        lastPrice = try c.decode(String.self, forKey: .last)
        highPrice = try c.decode(String.self, forKey: .high24h)
        lowPrice  = try c.decode(String.self, forKey: .low24h)
        volume    = try c.decode(String.self, forKey: .vol24h)
        bestBid   = try c.decode(String.self, forKey: .bidPx)
        bestAsk   = try c.decode(String.self, forKey: .askPx)

        let open      = try c.decode(String.self, forKey: .open24h)
        let lastVal   = Double(lastPrice) ?? 0
        let openVal   = Double(open) ?? 0
        let change    = lastVal - openVal
        let changePct = openVal != 0 ? (change / openVal * 100) : 0
        priceChange        = String(format: "%.8f", change)
        priceChangePercent = String(format: "%.4f", changePct)
    }
}
