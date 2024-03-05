import Foundation

struct HoldingEntry: Codable {
    let symbol: String
    let name: String
    var amount: Double
    var fiatValue: Double
}

final class WalletStorage {

    static let shared = WalletStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Key {
        static let balance  = "wallet.balance"
        static let holdings = "wallet.holdings"
    }

    var balance: Double {
        get { defaults.double(forKey: Key.balance) }
        set { defaults.set(newValue, forKey: Key.balance) }
    }

    var holdings: [HoldingEntry] {
        get {
            guard let data = defaults.data(forKey: Key.holdings),
                  let entries = try? JSONDecoder().decode([HoldingEntry].self, from: data)
            else { return [] }
            return entries
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Key.holdings)
        }
    }
}
