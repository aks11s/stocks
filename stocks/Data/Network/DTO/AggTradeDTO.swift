import Foundation

// Drives the live trade feed on the Detail screen
struct AggTradeDTO: Decodable {
    let symbol: String
    let price: String
    let quantity: String
    let tradeTime: Int64
    // Binance names this from the maker's perspective: true = sell hit the book (show red), false = buy hit the book (show green)
    let isBuyerMaker: Bool

    enum CodingKeys: String, CodingKey {
        case symbol       = "s"
        case price        = "p"
        case quantity     = "q"
        case tradeTime    = "T"
        case isBuyerMaker = "m"
    }
}
