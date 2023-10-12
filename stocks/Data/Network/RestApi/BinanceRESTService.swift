import Foundation

protocol BinanceRESTServiceProtocol {
    /// All 24h tickers — called once on Markets screen load
    func fetchAllTickers() async throws -> [TickerRESTDTO]
    /// Single symbol ticker — called when opening Detail screen
    func fetchTicker(symbol: String) async throws -> TickerRESTDTO
    /// Historical candles — loaded before WS stream takes over the chart
    func fetchKlines(symbol: String, interval: KlineInterval, limit: Int) async throws -> [KlineRESTDTO]
}

final class BinanceRESTService: BinanceRESTServiceProtocol {
    private let network: NetworkServiceProtocol

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    func fetchAllTickers() async throws -> [TickerRESTDTO] {
        try await network.request(.ticker24h())
    }

    func fetchTicker(symbol: String) async throws -> TickerRESTDTO {
        try await network.request(.ticker24h(symbol: symbol))
    }

    func fetchKlines(symbol: String, interval: KlineInterval, limit: Int = 500) async throws -> [KlineRESTDTO] {
        try await network.request(.klines(symbol: symbol, interval: interval, limit: limit))
    }
}
