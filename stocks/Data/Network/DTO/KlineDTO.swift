import Foundation

// Live candle update — arrives every tick, but we only append to chart history when isClosed is true
struct KlineDTO: Decodable {
    let symbol: String
    let candle: Candle

    struct Candle: Decodable {
        let openTime: Int64
        let closeTime: Int64
        let open: String
        let high: String
        let low: String
        let close: String
        let volume: String
        // Only when this is true should we finalize the candle in chart history — intermediate updates are just live previews
        let isClosed: Bool

        enum CodingKeys: String, CodingKey {
            case openTime  = "t"
            case closeTime = "T"
            case open      = "o"
            case high      = "h"
            case low       = "l"
            case close     = "c"
            case volume    = "v"
            case isClosed  = "x"
        }
    }

    enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case candle = "k"
    }
}
