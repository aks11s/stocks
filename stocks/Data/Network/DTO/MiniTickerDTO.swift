import Foundation

// Keeps prices current across the whole app — one stream for all symbols is much cheaper than a ticker per symbol
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
