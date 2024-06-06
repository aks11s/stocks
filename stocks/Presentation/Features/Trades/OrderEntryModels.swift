import Foundation

enum OrderSide: String, Codable {
    case buy
    case sell
}

enum OrderType: String, Codable {
    case limit
    case market
    case stopLimit
}
