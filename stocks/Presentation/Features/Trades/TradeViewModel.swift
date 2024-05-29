import Foundation

@MainActor
final class TradeViewModel {

    enum State {
        case loading
        case loaded(candles: [Candle], orderBook: OrderBook, price: Double, changePercent: Double)
        case error(String)
    }

    var onStateChange: ((State) -> Void)?

    // Emitted on each live candle tick — the VC updates only the last candle
    var onCandleTick: ((Candle) -> Void)?

    // Latest price from the live candle close — the VC updates only the price label
    var onPriceTick: ((Double) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private(set) var selectedInterval: KlineInterval = .oneMinute
    let symbol: String

    private let rest: OKXRESTServiceProtocol
    private let ws: OKXWebSocketServiceProtocol
    private var klineTask: Task<Void, Never>?

    init(
        symbol: String,
        rest: OKXRESTServiceProtocol = OKXRESTService(),
        ws: OKXWebSocketServiceProtocol = OKXWebSocketService()
    ) {
        self.symbol = symbol
        self.rest = rest
        self.ws = ws
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

            startLiveCandles()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func startLiveCandles() {
        klineTask?.cancel()
        ws.disconnect()
        ws.connect(streams: [.kline(symbol: symbol, interval: selectedInterval)])

        klineTask = Task { [weak self] in
            guard let self else { return }
            for await dto in ws.klineStream(symbol: symbol, interval: selectedInterval) {
                let candle = Candle(wsCandle: dto.candle)
                self.onCandleTick?(candle)
                self.onPriceTick?(candle.close)
            }
        }
    }

    deinit {
        klineTask?.cancel()
        ws.disconnect()
    }
}
