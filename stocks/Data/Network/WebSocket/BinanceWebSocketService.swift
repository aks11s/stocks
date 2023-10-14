import Foundation

protocol BinanceWebSocketServiceProtocol {
    func connect(streams: [BinanceStream])
    func disconnect()
    func miniTickerStream() -> AsyncStream<[MiniTickerDTO]>
    func tickerStream(symbol: String) -> AsyncStream<TickerDTO>
    func klineStream(symbol: String, interval: KlineInterval) -> AsyncStream<KlineDTO>
}

final class BinanceWebSocketService: BinanceWebSocketServiceProtocol {
    private let socket: WebSocketServiceProtocol
    private let decoder = JSONDecoder()

    // Keyed by stream name so the Detail screen can open kline and ticker for different symbols simultaneously
    private var miniTickerContinuation: AsyncStream<[MiniTickerDTO]>.Continuation?
    private var tickerContinuations: [String: AsyncStream<TickerDTO>.Continuation] = [:]
    private var klineContinuations:  [String: AsyncStream<KlineDTO>.Continuation]  = [:]

    init(socket: WebSocketServiceProtocol = WebSocketService()) {
        self.socket = socket
        self.socket.onData = { [weak self] data in self?.route(data) }
    }

    func connect(streams: [BinanceStream]) {
        socket.connect(url: BinanceStream.combinedURL(for: streams))
    }

    func disconnect() {
        socket.disconnect()
        miniTickerContinuation?.finish()
        tickerContinuations.values.forEach { $0.finish() }
        klineContinuations.values.forEach  { $0.finish() }
    }

    // MARK: - Stream factories

    func miniTickerStream() -> AsyncStream<[MiniTickerDTO]> {
        AsyncStream { [weak self] in self?.miniTickerContinuation = $0 }
    }

    func tickerStream(symbol: String) -> AsyncStream<TickerDTO> {
        AsyncStream { [weak self] in self?.tickerContinuations[symbol.lowercased()] = $0 }
    }

    func klineStream(symbol: String, interval: KlineInterval) -> AsyncStream<KlineDTO> {
        let key = BinanceStream.kline(symbol: symbol, interval: interval).name
        return AsyncStream { [weak self] in self?.klineContinuations[key] = $0 }
    }

    // MARK: - Message routing

    // Combined stream wraps every message in an envelope — we unwrap it first, then route by stream name
    private func route(_ data: Data) {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let streamName = json["stream"] as? String,
            let rawPayload = json["data"],
            let payload = try? JSONSerialization.data(withJSONObject: rawPayload)
        else { return }

        let sym = streamName.components(separatedBy: "@").first ?? ""

        if streamName == "!miniTicker@arr" {
            if let v = try? decoder.decode([MiniTickerDTO].self, from: payload) {
                miniTickerContinuation?.yield(v)
            }
        } else if streamName.hasSuffix("@ticker") {
            if let v = try? decoder.decode(TickerDTO.self, from: payload) {
                tickerContinuations[sym]?.yield(v)
            }
        } else if streamName.contains("@kline_") {
            if let v = try? decoder.decode(KlineDTO.self, from: payload) {
                klineContinuations[streamName]?.yield(v)
            }
        }
    }
}
