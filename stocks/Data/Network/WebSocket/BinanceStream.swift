import Foundation

enum DepthLevel: String {
    case five   = "5"
    case ten    = "10"
    case twenty = "20"
}

enum BinanceStream {
    /// Price + volume updates for every symbol — background feed for Home/Markets/Wallet
    case allMiniTickers
    /// Full 24h stats for one symbol — Detail screen header
    case ticker(symbol: String)
    /// OHLCV candles — Detail screen chart
    case kline(symbol: String, interval: KlineInterval)
    /// Order book — Detail screen depth view
    case depth(symbol: String, levels: DepthLevel = .twenty)
    /// Executed trades feed — Detail screen trade list
    case aggTrade(symbol: String)
    /// Best bid and ask — Detail screen buy/sell price display
    case bookTicker(symbol: String)

    var name: String {
        switch self {
        case .allMiniTickers:
            return "!miniTicker@arr"
        case .ticker(let symbol):
            return "\(symbol.lowercased())@ticker"
        case .kline(let symbol, let interval):
            return "\(symbol.lowercased())@kline_\(interval.rawValue)"
        case .depth(let symbol, let levels):
            return "\(symbol.lowercased())@depth\(levels.rawValue)"
        case .aggTrade(let symbol):
            return "\(symbol.lowercased())@aggTrade"
        case .bookTicker(let symbol):
            return "\(symbol.lowercased())@bookTicker"
        }
    }
}

extension BinanceStream {
    private static let wsBase = "wss://stream.binance.com:9443"

    /// Binance supports up to 1024 streams per connection — combining them avoids a separate WebSocket handshake per stream
    static func combinedURL(for streams: [BinanceStream]) -> URL {
        let names = streams.map { $0.name }.joined(separator: "/")
        return URL(string: "\(wsBase)/stream?streams=\(names)")!
    }
}
