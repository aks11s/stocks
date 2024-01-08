import Foundation

// MEXC miniTicker payload — one entry per symbol inside the "data" array
// MEXC field names: s=symbol, c=close, o=open, h=high, l=low, v=baseVolume, q=quoteVolume
struct MiniTickerDTO: Decodable {
    let symbol: String
    let closePrice: String
    let openPrice: String
    let highPrice: String
    let lowPrice: String
    let baseVolume: String
    let quoteVolume: String

    enum CodingKeys: String, CodingKey {
        case symbol      = "s"
        case closePrice  = "c"
        case openPrice   = "o"
        case highPrice   = "h"
        case lowPrice    = "l"
        case baseVolume  = "v"
        case quoteVolume = "q"
    }
}
