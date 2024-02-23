import Foundation

enum DepthLevel: String {
    case five   = "5"
    case ten    = "10"
    case twenty = "20"
}

enum OKXStream {
    // OKX has no global ticker stream — per-symbol subscriptions wired in commit 6
    case allMiniTickers
    case ticker(symbol: String)
    case kline(symbol: String, interval: KlineInterval)
    case depth(symbol: String, levels: DepthLevel)
    case aggTrade(symbol: String)
    case bookTicker(symbol: String)

    // Routing key used to match incoming OKX messages to the right continuation
    var name: String {
        switch self {
        case .allMiniTickers:
            return "tickers-all"
        case .ticker(let symbol):
            return "tickers|\(symbol)"
        case .kline(let symbol, let interval):
            return "candle\(interval.rawValue)|\(symbol)"
        case .depth(let symbol, _):
            return "books5|\(symbol)"
        case .aggTrade(let symbol):
            return "trades|\(symbol)"
        case .bookTicker(let symbol):
            return "bbo-tbt|\(symbol)"
        }
    }

    // OKX subscribe arg: {"channel":"...","instId":"..."} — nil for cases with no OKX equivalent
    var subscriptionArg: [String: String]? {
        switch self {
        case .allMiniTickers:
            return nil
        case .ticker(let symbol):
            return ["channel": "tickers", "instId": symbol]
        case .kline(let symbol, let interval):
            return ["channel": "candle\(interval.rawValue)", "instId": symbol]
        case .depth(let symbol, _):
            return ["channel": "books5", "instId": symbol]
        case .aggTrade(let symbol):
            return ["channel": "trades", "instId": symbol]
        case .bookTicker(let symbol):
            return ["channel": "bbo-tbt", "instId": symbol]
        }
    }
}

extension OKXStream {
    static let wsURL = URL(string: "wss://ws.okx.com:8443/ws/v5/public")!

    // OKX subscribe format: {"op":"subscribe","args":[{"channel":"...","instId":"..."},...]}
    static func subscriptionMessage(for streams: [OKXStream]) -> String {
        let args = streams.compactMap { $0.subscriptionArg }
        let argsJSON = args
            .map { "{\"channel\":\"\($0["channel"]!)\",\"instId\":\"\($0["instId"]!)\"}" }
            .joined(separator: ",")
        return "{\"op\":\"subscribe\",\"args\":[\(argsJSON)]}"
    }

    static func combinedURL(for streams: [OKXStream]) -> URL { wsURL }
}
