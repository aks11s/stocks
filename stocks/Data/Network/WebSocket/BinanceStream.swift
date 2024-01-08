import Foundation

enum DepthLevel: String {
    case five   = "5"
    case ten    = "10"
    case twenty = "20"
}

// Stream channel names match MEXC subscription format
enum BinanceStream {
    case allMiniTickers
    case ticker(symbol: String)
    case kline(symbol: String, interval: KlineInterval)
    case depth(symbol: String, levels: DepthLevel)
    case aggTrade(symbol: String)
    case bookTicker(symbol: String)

    // MEXC subscription channel name
    var name: String {
        switch self {
        case .allMiniTickers:
            return "spot@public.miniTickers.v3.api"
        case .ticker(let symbol):
            return "spot@public.bookTicker.v3.api@\(symbol)"
        case .kline(let symbol, let interval):
            return "spot@public.kline.v3.api@\(symbol)@\(interval.rawValue)"
        case .depth(let symbol, let levels):
            return "spot@public.limit.depth.v3.api@\(symbol)@\(levels.rawValue)"
        case .aggTrade(let symbol):
            return "spot@public.deals.v3.api@\(symbol)"
        case .bookTicker(let symbol):
            return "spot@public.bookTicker.v3.api@\(symbol)"
        }
    }
}

extension BinanceStream {
    // MEXC uses a single WS endpoint — channels are selected via SUBSCRIPTION messages after connect
    static let wsURL = URL(string: "wss://wbs-api.mexc.com/ws")!

    // JSON subscription message for a set of streams
    static func subscriptionMessage(for streams: [BinanceStream]) -> String {
        let params = streams.map { "\"\($0.name)\"" }.joined(separator: ",")
        return "{\"method\":\"SUBSCRIPTION\",\"params\":[\(params)]}"
    }

    // Legacy helper — kept so call sites compile unchanged
    static func combinedURL(for streams: [BinanceStream]) -> URL { wsURL }
}
