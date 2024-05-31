import Foundation

enum DepthLevel: String {
    case five   = "5"
    case ten    = "10"
    case twenty = "20"
}

enum OKXStream {
    // no global ticker stream, so we subscribe per symbol
    case allMiniTickers
    case ticker(symbol: String)
    case kline(symbol: String, interval: KlineInterval)
    case depth(symbol: String, levels: DepthLevel)
    case aggTrade(symbol: String)
    case bookTicker(symbol: String)

    // key we use to route an incoming message back to its continuation
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

    // the channel/instId pair OKX wants, or nil if there's nothing to subscribe to
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
    static let wsURL       = URL(string: "wss://ws.okx.com:8443/ws/v5/public")!
    // candles only come through the business endpoint, everything else is public
    static let businessURL = URL(string: "wss://ws.okx.com:8443/ws/v5/business")!

    var isBusinessChannel: Bool {
        if case .kline = self { return true }
        return false
    }

    // builds the {"op":"subscribe","args":[...]} payload OKX expects
    static func subscriptionMessage(for streams: [OKXStream]) -> String {
        let args = streams.compactMap { $0.subscriptionArg }
        let argsJSON = args
            .map { "{\"channel\":\"\($0["channel"]!)\",\"instId\":\"\($0["instId"]!)\"}" }
            .joined(separator: ",")
        return "{\"op\":\"subscribe\",\"args\":[\(argsJSON)]}"
    }

    static func endpoint(for streams: [OKXStream]) -> URL {
        streams.contains(where: \.isBusinessChannel) ? businessURL : wsURL
    }
}
