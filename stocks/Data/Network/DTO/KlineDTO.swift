import Foundation

struct KlineDTO {
    let symbol: String
    let candle: Candle

    struct Candle: Decodable {
        let openTime: Int64
        let open: String
        let high: String
        let low: String
        let close: String
        let volume: String
        let isClosed: Bool

        init(from decoder: Decoder) throws {
            var c = try decoder.unkeyedContainer()
            let tsString = try c.decode(String.self)
            openTime = Int64(tsString) ?? 0
            open     = try c.decode(String.self)
            high     = try c.decode(String.self)
            low      = try c.decode(String.self)
            close    = try c.decode(String.self)
            volume   = try c.decode(String.self)
            _ = try c.decode(String.self) // volCcy, unused
            _ = try c.decode(String.self) // volCcyQuote, unused
            // "1" means the candle is closed — only closed candles go into chart history
            let confirm = try c.decode(String.self)
            isClosed = confirm == "1"
        }
    }
}
