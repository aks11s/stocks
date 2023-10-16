import Foundation

// Order book snapshot for the depth view on Detail screen
// Prices and quantities come as strings — Binance does this to avoid floating-point precision loss
struct DepthDTO: Decodable {
    let bids: [[String]]
    let asks: [[String]]
}
