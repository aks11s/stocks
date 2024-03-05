import Foundation

final class WalletStorage {

    static let shared = WalletStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Key {
        static let balance = "wallet.balance"
    }

    var balance: Double {
        get { defaults.double(forKey: Key.balance) }
        set { defaults.set(newValue, forKey: Key.balance) }
    }
}
