import Foundation

protocol OKXRESTServiceProtocol {
    func fetchAllTickers() async throws -> [TickerRESTDTO]
    func fetchTicker(symbol: String) async throws -> TickerRESTDTO
    func fetchKlines(symbol: String, interval: KlineInterval, limit: Int) async throws -> [KlineRESTDTO]
}

final class OKXRESTService: OKXRESTServiceProtocol {
    private let network: NetworkServiceProtocol

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    func fetchAllTickers() async throws -> [TickerRESTDTO] {
        try await network.request(.allTickers)
    }

    func fetchTicker(symbol: String) async throws -> TickerRESTDTO {
        let list: [TickerRESTDTO] = try await network.request(.ticker(instId: symbol))
        guard let ticker = list.first else { throw URLError(.badServerResponse) }
        return ticker
    }

    func fetchKlines(symbol: String, interval: KlineInterval, limit: Int = 500) async throws -> [KlineRESTDTO] {
        try await network.request(.candles(instId: symbol, bar: interval, limit: limit))
    }
}
