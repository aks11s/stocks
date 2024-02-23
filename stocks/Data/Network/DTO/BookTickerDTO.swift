import Foundation

struct BookTickerDTO: Decodable {
    let symbol: String
    let bidPrice: String
    let bidQty: String
    let askPrice: String
    let askQty: String

    enum CodingKeys: String, CodingKey {
        case symbol   = "instId"
        case bidPrice = "bidPx"
        case bidQty   = "bidSz"
        case askPrice = "askPx"
        case askQty   = "askSz"
    }
}
