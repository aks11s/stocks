import Foundation

@MainActor
final class MarketViewModel {

    // MARK: - State

    enum State {
        case loading
        case loaded([MarketToken])
        case error(String)
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    // MARK: - Dependencies

    private let rest: OKXRESTServiceProtocol
    private let ws:   OKXWebSocketServiceProtocol
    private let favorites = FavoritesStorage.shared

    private var tokens: [MarketToken] = []
    private var wsTask: Task<Void, Never>?

    init(
        rest: OKXRESTServiceProtocol = OKXRESTService(),
        ws:   OKXWebSocketServiceProtocol = OKXWebSocketService()
    ) {
        self.rest = rest
        self.ws   = ws
    }

    // MARK: - Load

    func load() {
        Task {
            state = .loading
            do {
                let symbols = favorites.symbols
                tokens = try await fetchTokens(symbols: symbols)
                state = .loaded(tokens)
                startLiveUpdates()
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func reload() {
        wsTask?.cancel()
        load()
    }

    // MARK: - Favorites

    func removeFavorite(at index: Int) {
        guard index < tokens.count else { return }
        let symbol = tokens[index].symbol
        favorites.remove(symbol)
        tokens.remove(at: index)
        state = .loaded(tokens)
    }

    // MARK: - Private

    // Fetch tickers + klines for each symbol concurrently.
    // Individual symbol failures are swallowed so one delisted pair doesn't break the whole screen.
    private func fetchTokens(symbols: [String]) async throws -> [MarketToken] {
        await withTaskGroup(of: MarketToken?.self) { group in
            for symbol in symbols {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    do {
                        async let ticker = rest.fetchTicker(symbol: symbol)
                        async let klines = rest.fetchKlines(symbol: symbol, interval: .oneHour, limit: 20)
                        let (t, k) = try await (ticker, klines)
                        let points = k.compactMap { Double($0.close) }
                        return MarketToken.from(
                            symbol: symbol,
                            price: t.lastPrice,
                            changePercent: t.priceChangePercent,
                            klines: points
                        )
                    } catch {
                        print("⚠️ fetchTokens: \(symbol) failed — \(error)")
                        return nil
                    }
                }
            }
            var result: [MarketToken?] = []
            for await token in group { result.append(token) }
            // Preserve favorites order
            return symbols.compactMap { sym in result.first(where: { $0?.symbol == sym }) ?? nil }
        }
    }

    private func startLiveUpdates() {
        let streams: [OKXStream] = [.allMiniTickers]
        ws.connect(streams: streams)

        wsTask = Task { [weak self] in
            guard let self else { return }
            for await tickers in ws.miniTickerStream() {
                let favoriteSet = Set(self.favorites.symbols)
                var changed = false
                for ticker in tickers where favoriteSet.contains(ticker.symbol) {
                    if let idx = self.tokens.firstIndex(where: { $0.symbol == ticker.symbol }) {
                        self.tokens[idx].applyTicker(close: ticker.closePrice, open: ticker.openPrice)
                        changed = true
                    }
                }
                if changed { self.state = .loaded(self.tokens) }
            }
        }
    }

    deinit {
        wsTask?.cancel()
        ws.disconnect()
    }
}
