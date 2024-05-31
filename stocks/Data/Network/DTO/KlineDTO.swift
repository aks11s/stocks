import Foundation

// OKX candle WS row: [ts, open, high, low, close, vol, volCcy, volCcyQuote, confirm]
// the symbol isn't in the row, OKXWebSocketService fills it from arg.instId
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
        // confirm == "1" means the candle closed; only then update chart history
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
            _ = try c.decode(String.self) // volCcy
            _ = try c.decode(String.self) // volCcyQuote
            let confirm = try c.decode(String.self)
            isClosed = confirm == "1"
        }
    }
}
