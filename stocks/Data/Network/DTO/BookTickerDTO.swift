import Foundation

// Real-time best bid/ask — used on buy/sell buttons so the user sees the actual market price, not a stale ticker value
struct BookTickerDTO: Decodable {
    let symbol: String
    let bidPrice: String
    let bidQty: String
    let askPrice: String
    let askQty: String

    enum CodingKeys: String, CodingKey {
        case symbol   = "s"
        case bidPrice = "b"
        case bidQty   = "B"
        case askPrice = "a"
        case askQty   = "A"
    }
}
