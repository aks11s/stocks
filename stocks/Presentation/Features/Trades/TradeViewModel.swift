import Foundation

@MainActor
final class TradeViewModel {

    enum State {
        case loading
        case loaded(candles: [Candle], orderBook: OrderBook, price: Double, changePercent: Double)
        case error(String)
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private(set) var selectedInterval: KlineInterval = .oneMinute
    let symbol: String

    private let rest: OKXRESTServiceProtocol

    init(symbol: String, rest: OKXRESTServiceProtocol = OKXRESTService()) {
        self.symbol = symbol
        self.rest = rest
    }

    func load() {
        state = .loading
        Task { [weak self] in
            await self?.fetch()
        }
    }

    func selectInterval(_ interval: KlineInterval) {
        guard interval != selectedInterval else { return }
        selectedInterval = interval
        Task { [weak self] in
            await self?.fetch()
        }
    }

    // MARK: - Private

    private func fetch() async {
        do {
            async let klinesDTOs = rest.fetchKlines(symbol: symbol, interval: selectedInterval, limit: 100)
            async let tickerDTO  = rest.fetchTicker(symbol: symbol)
            async let depthDTO   = rest.fetchDepth(symbol: symbol)

            let (klines, ticker, depth) = try await (klinesDTOs, tickerDTO, depthDTO)

            let candles    = klines.map { Candle(dto: $0) }.reversed()
            let orderBook  = OrderBook(dto: depth)
            let price      = Double(ticker.lastPrice) ?? 0
            let changePct  = Double(ticker.priceChangePercent) ?? 0

            state = .loaded(
                candles: Array(candles),
                orderBook: orderBook,
                price: price,
                changePercent: changePct
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
