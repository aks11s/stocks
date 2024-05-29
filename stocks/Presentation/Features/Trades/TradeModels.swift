import Foundation

struct Candle {
    let timestamp: Int64
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
}

struct OrderBookEntry {
    let price: Double
    let amount: Double
}

struct OrderBook {
    let bids: [OrderBookEntry]
    let asks: [OrderBookEntry]
}

extension Candle {
    init(dto: KlineRESTDTO) {
        timestamp = dto.openTime
        open      = Double(dto.open)   ?? 0
        high      = Double(dto.high)   ?? 0
        low       = Double(dto.low)    ?? 0
        close     = Double(dto.close)  ?? 0
        volume    = Double(dto.volume) ?? 0
    }

    init(wsCandle c: KlineDTO.Candle) {
        timestamp = c.openTime
        open      = Double(c.open)   ?? 0
        high      = Double(c.high)   ?? 0
        low       = Double(c.low)    ?? 0
        close     = Double(c.close)  ?? 0
        volume    = Double(c.volume) ?? 0
    }
}

extension OrderBook {
    init(dto: DepthDTO) {
        bids = dto.bids.compactMap { row -> OrderBookEntry? in
            guard row.count >= 2,
                  let price  = Double(row[0]),
                  let amount = Double(row[1]) else { return nil }
            return OrderBookEntry(price: price, amount: amount)
        }
        asks = dto.asks.compactMap { row -> OrderBookEntry? in
            guard row.count >= 2,
                  let price  = Double(row[0]),
                  let amount = Double(row[1]) else { return nil }
            return OrderBookEntry(price: price, amount: amount)
        }
    }
}
