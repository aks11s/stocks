import Foundation

enum BinanceEndpoint {
    static let baseURL = "https://api.binance.com"

    /// 24h rolling ticker stats; pass nil to fetch all symbols at once
    case ticker24h(symbol: String? = nil)

    var url: URL {
        URL(string: BinanceEndpoint.baseURL + path)!
    }

    var path: String {
        switch self {
        case .ticker24h: return "/api/v3/ticker/24hr"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .ticker24h(let symbol):
            guard let symbol else { return nil }
            return ["symbol": symbol]
        }
    }
}
