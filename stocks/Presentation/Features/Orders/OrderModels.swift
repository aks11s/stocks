import Foundation

enum OrderStatus: String, Codable {
    case pending
    case filled
    case cancelled
}

struct Order: Codable {
    let id: UUID
    let symbol: String
    let side: OrderSide
    let type: OrderType
    let price: Double
    let quantity: Double
    let total: Double
    let date: Date
    var status: OrderStatus

    init(
        id: UUID = UUID(),
        symbol: String,
        side: OrderSide,
        type: OrderType,
        price: Double,
        quantity: Double,
        total: Double,
        date: Date = Date(),
        status: OrderStatus
    ) {
        self.id       = id
        self.symbol   = symbol
        self.side     = side
        self.type     = type
        self.price    = price
        self.quantity = quantity
        self.total    = total
        self.date     = date
        self.status   = status
    }
}
