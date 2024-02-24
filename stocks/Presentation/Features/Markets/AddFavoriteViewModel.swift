import Foundation

struct SearchToken {
    let symbol: String    // BTC-USDT
    let pair: String      // BTC/USDT
    let logoName: String
    let price: String
    var isAdded: Bool
}

@MainActor
final class AddFavoriteViewModel {

    enum State {
        case idle
        case loading
        case loaded([SearchToken])
        case error(String)
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

    private let rest: OKXRESTServiceProtocol
    private let favorites = FavoritesStorage.shared

    // Full unfiltered list fetched once
    private var allTokens: [SearchToken] = []

    init(rest: OKXRESTServiceProtocol = OKXRESTService()) {
        self.rest = rest
    }

    // MARK: - Load

    func load() {
        Task {
            state = .loading
            do {
                let tickers = try await rest.fetchAllTickers()
                // Keep only USDT pairs and sort by quote volume descending
                allTokens = tickers
                    .filter { $0.symbol.hasSuffix("-USDT") }
                    .sorted {
                        (Double($0.quoteVolume) ?? 0) > (Double($1.quoteVolume) ?? 0)
                    }
                    .map { makeSearchToken(from: $0) }
                state = .loaded(allTokens)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Search

    func search(_ query: String) {
        let q = query.trimmingCharacters(in: .whitespaces).uppercased()
        if q.isEmpty {
            state = .loaded(allTokens)
        } else {
            let filtered = allTokens.filter {
                $0.pair.contains(q) || $0.symbol.contains(q)
            }
            state = .loaded(filtered)
        }
    }

    // MARK: - Add

    func addFavorite(symbol: String) {
        favorites.add(symbol)

        // Reflect isAdded in both allTokens and current results
        update(symbol: symbol, isAdded: true)
    }

    // MARK: - Private

    private func makeSearchToken(from ticker: TickerRESTDTO) -> SearchToken {
        let symbol = ticker.symbol
        let meta = MarketToken.metadata[symbol]
        let base = meta?.base ?? symbol.replacingOccurrences(of: "-USDT", with: "")
        let logo = meta?.logo ?? "logo_all"
        let price = formatPrice(ticker.lastPrice)
        return SearchToken(
            symbol: symbol,
            pair: "\(base)/USDT",
            logoName: logo,
            price: price,
            isAdded: favorites.contains(symbol)
        )
    }

    private func update(symbol: String, isAdded: Bool) {
        func apply(_ tokens: inout [SearchToken]) {
            if let i = tokens.firstIndex(where: { $0.symbol == symbol }) {
                tokens[i].isAdded = isAdded
            }
        }
        apply(&allTokens)
        if case .loaded(var current) = state {
            apply(&current)
            state = .loaded(current)
        }
    }

    private func formatPrice(_ raw: String) -> String {
        guard let v = Double(raw) else { return raw }
        if v >= 1000 { return String(format: "$%.2f", v) }
        if v >= 1    { return String(format: "$%.4f", v) }
        return "$" + String(format: "%.8f", v)
            .replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
    }
}
