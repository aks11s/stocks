import Foundation

struct MarketToken {
    let symbol: String       // BTC
    let name: String         // Bitcoin
    let pair: String         // BTC/USDT
    let logoName: String     // asset name
    let price: String
    let change: String
    let isUptrend: Bool
    // Mock sparkline data — 20 points trending up or down
    let chartPoints: [Double]
}

final class MarketViewModel {

    let tokens: [MarketToken] = [
        MarketToken(
            symbol: "BTC", name: "Bitcoin", pair: "BTC/USDT",
            logoName: "logo_btc",
            price: "32,697.05", change: "+0.81%", isUptrend: true,
            chartPoints: [28, 27, 29, 31, 30, 32, 31, 33, 35, 34, 36, 35, 37, 38, 37, 39, 38, 40, 39, 41]
        ),
        MarketToken(
            symbol: "SOL", name: "Solana", pair: "SOL/USDT",
            logoName: "logo_sol",
            price: "21.48", change: "+0.81%", isUptrend: true,
            chartPoints: [20, 19, 21, 22, 21, 23, 22, 24, 23, 25, 24, 26, 25, 27, 26, 28, 27, 29, 28, 30]
        ),
        MarketToken(
            symbol: "ADA", name: "Cardano", pair: "ADA/USDT",
            logoName: "logo_ada",
            price: "0.3812", change: "+0.81%", isUptrend: true,
            chartPoints: [10, 11, 10, 12, 11, 13, 12, 14, 13, 15, 14, 16, 15, 17, 16, 18, 17, 19, 18, 20]
        ),
        MarketToken(
            symbol: "SHIB", name: "SHIBA INU", pair: "SHIB/USDT",
            logoName: "logo_shib",
            price: "0.000008", change: "-0.81%", isUptrend: false,
            chartPoints: [40, 39, 41, 38, 39, 37, 38, 36, 37, 35, 36, 34, 35, 33, 34, 32, 33, 31, 32, 30]
        ),
        MarketToken(
            symbol: "MFT", name: "Hifi Finance", pair: "MFT/USDT",
            logoName: "logo_mft",
            price: "0.0041", change: "-0.81%", isUptrend: false,
            chartPoints: [30, 29, 31, 28, 29, 27, 28, 26, 27, 25, 26, 24, 25, 23, 24, 22, 23, 21, 22, 20]
        ),
        MarketToken(
            symbol: "REN", name: "Ren", pair: "REN/USDT",
            logoName: "logo_ren",
            price: "0.0624", change: "-0.81%", isUptrend: false,
            chartPoints: [25, 24, 26, 23, 24, 22, 23, 21, 22, 20, 21, 19, 20, 18, 19, 17, 18, 16, 17, 15]
        )
    ]
}
