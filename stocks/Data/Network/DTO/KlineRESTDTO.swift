import Foundation

// Pre-loads chart history so the user sees a full chart immediately, before the WS stream takes over
// Binance sends each candle as a plain array of mixed types, so we need a custom decoder instead of CodingKeys
struct KlineRESTDTO: Decodable {
    let openTime: Int64
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
    let closeTime: Int64

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        openTime  = try c.decode(Int64.self)
        open      = try c.decode(String.self)
        high      = try c.decode(String.self)
        low       = try c.decode(String.self)
        close     = try c.decode(String.self)
        volume    = try c.decode(String.self)
        closeTime = try c.decode(Int64.self)
        // fields 8–11 (quoteVolume, tradeCount, etc.) are unused — skip
    }
}
