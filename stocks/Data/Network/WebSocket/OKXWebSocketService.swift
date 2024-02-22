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

    private func route(_ data: Data) {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let channel = json["c"] as? String,
            let rawPayload = json["d"],
            let payload = try? JSONSerialization.data(withJSONObject: rawPayload)
        else { return }

        if channel == "spot@public.miniTickers.v3.api" {
            if let wrapper = json["d"] as? [String: Any],
               let arr = wrapper["data"],
               let arrData = try? JSONSerialization.data(withJSONObject: arr),
               let v = try? decoder.decode([MiniTickerDTO].self, from: arrData) {
                miniTickerContinuation?.yield(v)
            }
        } else if channel.contains("kline") {
            if let v = try? decoder.decode(KlineDTO.self, from: payload) {
                klineContinuations[channel]?.yield(v)
            }
        } else if channel.contains("depth") {
            if let v = try? decoder.decode(DepthDTO.self, from: payload) {
                let sym = channel.components(separatedBy: "@").dropFirst(3).first ?? ""
                depthContinuations[sym.lowercased()]?.yield(v)
            }
        } else if channel.contains("deals") {
            if let v = try? decoder.decode(AggTradeDTO.self, from: payload) {
                let sym = channel.components(separatedBy: "@").dropFirst(3).first ?? ""
                aggTradeContinuations[sym.lowercased()]?.yield(v)
            }
        } else if channel.contains("bookTicker") {
            if let v = try? decoder.decode(BookTickerDTO.self, from: payload) {
                let sym = channel.components(separatedBy: "@").dropFirst(3).first ?? ""
                bookTickerContinuations[sym.lowercased()]?.yield(v)
            }
        }
    }
}
