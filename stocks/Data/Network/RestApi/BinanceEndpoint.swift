import Foundation

enum KlineInterval: String, CaseIterable {
    case oneMinute       = "1m"
    case fiveMinutes     = "5m"
    case fifteenMinutes  = "15m"
    case thirtyMinutes   = "30m"
    case oneHour         = "1h"
    case fourHours       = "4h"
    case oneDay          = "1d"
    case oneWeek         = "1w"
}

enum BinanceEndpoint {
    static let baseURL = "https://api.mexc.com"

    /// 24h rolling ticker stats; pass nil to fetch all symbols at once
    case ticker24h(symbol: String? = nil)
    /// Limit defaults to 500 — enough to fill a chart without hitting Binance's 1000-row cap
    case klines(symbol: String, interval: KlineInterval, limit: Int = 500)

    var url: URL {
        URL(string: BinanceEndpoint.baseURL + path)!
    }

    var path: String {
        switch self {
        case .ticker24h: return "/api/v3/ticker/24hr"
        case .klines:    return "/api/v3/klines"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .ticker24h(let symbol):
            guard let symbol else { return nil }
            return ["symbol": symbol]
        case .klines(let symbol, let interval, let limit):
            return ["symbol": symbol, "interval": interval.rawValue, "limit": limit]
        }
    }
}
