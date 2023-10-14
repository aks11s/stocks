import Foundation

enum BinanceStream {
    /// Price + volume updates for every symbol — background feed for Home/Markets/Wallet
    case allMiniTickers
    /// Full 24h stats for one symbol — Detail screen header
    case ticker(symbol: String)
    /// OHLCV candles — Detail screen chart
    case kline(symbol: String, interval: KlineInterval)

    var name: String {
        switch self {
        case .allMiniTickers:
            return "!miniTicker@arr"
        case .ticker(let symbol):
            return "\(symbol.lowercased())@ticker"
        case .kline(let symbol, let interval):
            return "\(symbol.lowercased())@kline_\(interval.rawValue)"
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
