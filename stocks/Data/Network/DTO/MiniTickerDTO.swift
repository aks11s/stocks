import Foundation

struct MiniTickerDTO: Decodable {
    let symbol: String
    let closePrice: String
    let openPrice: String

    enum CodingKeys: String, CodingKey {
        case symbol     = "instId"
        case closePrice = "last"
        case openPrice  = "open24h"
    }
}
