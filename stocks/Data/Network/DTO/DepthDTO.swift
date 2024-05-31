import Foundation

// order book snapshot for the trade screen
// price/qty come as strings to dodge float rounding
struct DepthDTO: Decodable {
    let bids: [[String]]
    let asks: [[String]]
}
