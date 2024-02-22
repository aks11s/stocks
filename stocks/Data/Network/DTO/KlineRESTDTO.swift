import Foundation

// OKX candles arrive as string arrays: [ts, open, high, low, close, vol, volCcy, volCcyQuote, confirm]
struct KlineRESTDTO: Decodable {
    let openTime: Int64
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        let tsString = try c.decode(String.self)
        openTime = Int64(tsString) ?? 0
        open     = try c.decode(String.self)
        high     = try c.decode(String.self)
        low      = try c.decode(String.self)
        close    = try c.decode(String.self)
        volume   = try c.decode(String.self)
        // volCcy, volCcyQuote, confirm — unused
    }
}
