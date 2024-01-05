import Foundation

// Persists the user's favorite trading pairs across sessions.
// Pre-seeded with the 6 tokens shown in the Figma design on first launch.
final class FavoritesStorage {

    static let shared = FavoritesStorage()
    private init() {
        if defaults.object(forKey: Key.symbols) == nil {
            defaults.set(Self.defaults_symbols, forKey: Key.symbols)
        }
    }

    private let defaults = UserDefaults.standard

    private enum Key {
        static let symbols = "favorites.symbols"
    }

    private static let defaults_symbols = [
        "BTCUSDT", "SOLUSDT", "ADAUSDT",
        "SHIBUSDT", "MFTUSDT", "RENUSDT"
    ]

    var symbols: [String] {
        get { defaults.stringArray(forKey: Key.symbols) ?? [] }
        set { defaults.set(newValue, forKey: Key.symbols) }
    }

    func contains(_ symbol: String) -> Bool {
        symbols.contains(symbol)
    }

    func add(_ symbol: String) {
        guard !contains(symbol) else { return }
        symbols.append(symbol)
    }

    func remove(_ symbol: String) {
        symbols.removeAll { $0 == symbol }
    }
}
