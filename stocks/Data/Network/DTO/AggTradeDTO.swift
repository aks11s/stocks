import Foundation

struct AggTradeDTO: Decodable {
    let symbol: String
    let price: String
    let quantity: String
    let tradeTime: Int64
    // OKX side is the taker's side: "sell" taker means buyer is maker (show red), "buy" taker means seller is maker (show green)
    let isBuyerMaker: Bool

    private enum CodingKeys: String, CodingKey {
        case instId = "instId"
        case px     = "px"
        case sz     = "sz"
        case ts     = "ts"
        case side   = "side"
    }

    init(from decoder: Decoder) throws {
        let c    = try decoder.container(keyedBy: CodingKeys.self)
        symbol   = try c.decode(String.self, forKey: .instId)
        price    = try c.decode(String.self, forKey: .px)
        quantity = try c.decode(String.self, forKey: .sz)
        let tsStr = try c.decode(String.self, forKey: .ts)
        tradeTime    = Int64(tsStr) ?? 0
        let side     = try c.decode(String.self, forKey: .side)
        isBuyerMaker = (side == "sell")
    }
}
