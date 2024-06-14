import Foundation

struct DepthDTO: Decodable {
    let bids: [[String]]
    let asks: [[String]]
}
