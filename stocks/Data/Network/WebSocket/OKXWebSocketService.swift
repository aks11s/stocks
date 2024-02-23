import Foundation

protocol OKXWebSocketServiceProtocol {
    func connect(streams: [OKXStream])
    func disconnect()
    func miniTickerStream() -> AsyncStream<[MiniTickerDTO]>
    func tickerStream(symbol: String) -> AsyncStream<TickerDTO>
    func klineStream(symbol: String, interval: KlineInterval) -> AsyncStream<KlineDTO>
    func depthStream(symbol: String) -> AsyncStream<DepthDTO>
    func aggTradeStream(symbol: String) -> AsyncStream<AggTradeDTO>
    func bookTickerStream(symbol: String) -> AsyncStream<BookTickerDTO>
}

final class OKXWebSocketService: OKXWebSocketServiceProtocol {
    private let socket: WebSocketServiceProtocol
    private let decoder = JSONDecoder()

    private var pendingStreams: [OKXStream] = []

    private var miniTickerContinuation: AsyncStream<[MiniTickerDTO]>.Continuation?
    private var tickerContinuations:     [String: AsyncStream<TickerDTO>.Continuation]     = [:]
    private var klineContinuations:      [String: AsyncStream<KlineDTO>.Continuation]      = [:]
    private var depthContinuations:      [String: AsyncStream<DepthDTO>.Continuation]      = [:]
    private var aggTradeContinuations:   [String: AsyncStream<AggTradeDTO>.Continuation]   = [:]
    private var bookTickerContinuations: [String: AsyncStream<BookTickerDTO>.Continuation] = [:]

    init(socket: WebSocketServiceProtocol = WebSocketService()) {
        self.socket = socket
        self.socket.onData = { [weak self] data in self?.route(data) }
        self.socket.onConnect = { [weak self] in
            guard let self else { return }
            let msg = OKXStream.subscriptionMessage(for: self.pendingStreams)
            self.socket.send(msg)
        }
    }

    func connect(streams: [OKXStream]) {
        pendingStreams = streams
        socket.connect(url: OKXStream.wsURL)
    }

    func disconnect() {
        socket.disconnect()
        miniTickerContinuation?.finish()
        tickerContinuations.values.forEach     { $0.finish() }
        klineContinuations.values.forEach      { $0.finish() }
        depthContinuations.values.forEach      { $0.finish() }
        aggTradeContinuations.values.forEach   { $0.finish() }
        bookTickerContinuations.values.forEach { $0.finish() }
    }

    // MARK: - Stream factories

    func miniTickerStream() -> AsyncStream<[MiniTickerDTO]> {
        AsyncStream { [weak self] in self?.miniTickerContinuation = $0 }
    }

    func tickerStream(symbol: String) -> AsyncStream<TickerDTO> {
        AsyncStream { [weak self] in self?.tickerContinuations[symbol.lowercased()] = $0 }
    }

    func klineStream(symbol: String, interval: KlineInterval) -> AsyncStream<KlineDTO> {
        let key = OKXStream.kline(symbol: symbol, interval: interval).name
        return AsyncStream { [weak self] in self?.klineContinuations[key] = $0 }
    }

    func depthStream(symbol: String) -> AsyncStream<DepthDTO> {
        AsyncStream { [weak self] in self?.depthContinuations[symbol.lowercased()] = $0 }
    }

    func aggTradeStream(symbol: String) -> AsyncStream<AggTradeDTO> {
        AsyncStream { [weak self] in self?.aggTradeContinuations[symbol.lowercased()] = $0 }
    }

    func bookTickerStream(symbol: String) -> AsyncStream<BookTickerDTO> {
        AsyncStream { [weak self] in self?.bookTickerContinuations[symbol.lowercased()] = $0 }
    }

    // MARK: - Message routing

    // OKX envelope: {"arg":{"channel":"...","instId":"..."},"data":[...]}
    private func route(_ data: Data) {
        guard
            let json     = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let arg      = json["arg"] as? [String: String],
            let channel  = arg["channel"],
            let instId   = arg["instId"],
            let rawData  = json["data"] as? [Any],
            !rawData.isEmpty
        else { return }

        let routingKey = "\(channel)|\(instId)"

        if channel == "tickers" {
            guard
                let item     = rawData.first,
                let itemData = try? JSONSerialization.data(withJSONObject: item)
            else { return }
            if let mini = try? decoder.decode(MiniTickerDTO.self, from: itemData) {
                miniTickerContinuation?.yield([mini])
            }
            if let ticker = try? decoder.decode(TickerDTO.self, from: itemData) {
                tickerContinuations[instId.lowercased()]?.yield(ticker)
            }
        } else if channel.hasPrefix("candle") {
            guard
                let candleArray = rawData.first,
                let candleData  = try? JSONSerialization.data(withJSONObject: candleArray),
                let candle      = try? decoder.decode(KlineDTO.Candle.self, from: candleData)
            else { return }
            klineContinuations[routingKey]?.yield(KlineDTO(symbol: instId, candle: candle))
        } else if channel == "books5" {
            guard
                let item     = rawData.first,
                let itemData = try? JSONSerialization.data(withJSONObject: item),
                let depth    = try? decoder.decode(DepthDTO.self, from: itemData)
            else { return }
            depthContinuations[instId.lowercased()]?.yield(depth)
        } else if channel == "trades" {
            guard
                let item     = rawData.first,
                let itemData = try? JSONSerialization.data(withJSONObject: item),
                let trade    = try? decoder.decode(AggTradeDTO.self, from: itemData)
            else { return }
            aggTradeContinuations[instId.lowercased()]?.yield(trade)
        } else if channel == "bbo-tbt" {
            guard
                let item       = rawData.first,
                let itemData   = try? JSONSerialization.data(withJSONObject: item),
                let bookTicker = try? decoder.decode(BookTickerDTO.self, from: itemData)
            else { return }
            bookTickerContinuations[instId.lowercased()]?.yield(bookTicker)
        }
    }
}
