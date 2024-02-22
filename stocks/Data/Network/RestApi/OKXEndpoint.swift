import Foundation

enum KlineInterval: String, CaseIterable {
    case oneMinute       = "1m"
    case fiveMinutes     = "5m"
    case fifteenMinutes  = "15m"
    case thirtyMinutes   = "30m"
    case oneHour         = "1H"
    case fourHours       = "4H"
    case oneDay          = "1D"
    case oneWeek         = "1W"
}

enum OKXEndpoint {
    static let baseURL = "https://www.okx.com/api/v5"

    case allTickers
    case ticker(instId: String)
    case candles(instId: String, bar: KlineInterval, limit: Int = 500)

    var url: URL {
        URL(string: OKXEndpoint.baseURL + path)!
    }

    var path: String {
        switch self {
        case .allTickers:  return "/market/tickers"
        case .ticker:      return "/market/ticker"
        case .candles:     return "/market/candles"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .allTickers:
            return ["instType": "SPOT"]
        case .ticker(let instId):
            return ["instId": instId]
        case .candles(let instId, let bar, let limit):
            return ["instId": instId, "bar": bar.rawValue, "limit": limit]
        }
    }
}
