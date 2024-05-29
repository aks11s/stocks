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

    // Emitted on each live depth snapshot — the VC re-renders the order book
    var onOrderBookTick: ((OrderBook) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private(set) var selectedInterval: KlineInterval = .oneMinute
    let symbol: String

    private let rest: OKXRESTServiceProtocol
    // Candlesticks use the OKX "business" endpoint; depth uses "public" — they need separate sockets
    private let candleWS: OKXWebSocketServiceProtocol
    private let depthWS: OKXWebSocketServiceProtocol
    private var klineTask: Task<Void, Never>?
    private var depthTask: Task<Void, Never>?

    init(
        symbol: String,
        rest: OKXRESTServiceProtocol = OKXRESTService(),
        candleWS: OKXWebSocketServiceProtocol = OKXWebSocketService(),
        depthWS: OKXWebSocketServiceProtocol = OKXWebSocketService()
    ) {
        self.symbol = symbol
        self.rest = rest
        self.candleWS = candleWS
        self.depthWS = depthWS
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
            startLiveOrderBookIfNeeded()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func startLiveCandles() {
        klineTask?.cancel()
        candleWS.disconnect()
        candleWS.connect(streams: [.kline(symbol: symbol, interval: selectedInterval)])

        klineTask = Task { [weak self] in
            guard let self else { return }
            for await dto in candleWS.klineStream(symbol: symbol, interval: selectedInterval) {
                let candle = Candle(wsCandle: dto.candle)
                self.onCandleTick?(candle)
                self.onPriceTick?(candle.close)
            }
        }
    }

    // Depth is interval-independent, so subscribe only once — interval changes don't touch it
    private func startLiveOrderBookIfNeeded() {
        guard depthTask == nil else { return }
        depthWS.connect(streams: [.depth(symbol: symbol, levels: .five)])

        depthTask = Task { [weak self] in
            guard let self else { return }
            for await dto in depthWS.depthStream(symbol: symbol) {
                self.onOrderBookTick?(OrderBook(dto: dto))
            }
        }
    }

    deinit {
        klineTask?.cancel()
        depthTask?.cancel()
        candleWS.disconnect()
        depthWS.disconnect()
    }
}
