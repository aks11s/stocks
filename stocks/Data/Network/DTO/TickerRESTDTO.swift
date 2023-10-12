import Foundation

// Initial snapshot for the Markets screen — REST call on first open, then WS miniTicker takes over
struct TickerRESTDTO: Decodable {
    let symbol: String
    let lastPrice: String
    let priceChange: String
    let priceChangePercent: String
    let highPrice: String
    let lowPrice: String
    let volume: String
    let quoteVolume: String
}
