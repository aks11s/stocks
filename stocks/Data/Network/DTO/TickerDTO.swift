import Foundation

// Richer than MiniTicker — includes bid/ask and percentage change, so we use this on the Detail screen instead
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

    enum CodingKeys: String, CodingKey {
        case symbol             = "s"
        case lastPrice          = "c"
        case priceChange        = "p"
        case priceChangePercent = "P"
        case highPrice          = "h"
        case lowPrice           = "l"
        case volume             = "v"
        case bestBid            = "b"
        case bestAsk            = "a"
    }
}
