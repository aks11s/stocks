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

    // MARK: - Trades

    // take the cost off the balance and fold the amount into holdings
    func buy(symbol: String, name: String, amount: Double, cost: Double) {
        balance -= cost

        var current = holdings
        if let index = current.firstIndex(where: { $0.symbol == symbol }) {
            current[index].amount    += amount
            current[index].fiatValue += cost
        } else {
            current.append(HoldingEntry(symbol: symbol, name: name, amount: amount, fiatValue: cost))
        }
        holdings = current
    }

    // add the proceeds back and shrink (or remove) the holding
    func sell(symbol: String, amount: Double, proceeds: Double) {
        balance += proceeds

        var current = holdings
        guard let index = current.firstIndex(where: { $0.symbol == symbol }) else { return }

        let entry = current[index]
        let remaining = entry.amount - amount
        if remaining > 0.0000_0001 {
            // scale fiatValue down by how much we sold
            let soldFraction = amount / entry.amount
            current[index].amount    = remaining
            current[index].fiatValue = entry.fiatValue * (1 - soldFraction)
        } else {
            current.remove(at: index)
        }
        holdings = current
    }
}
