import Foundation

@MainActor
final class PairPickerViewModel {

    struct Item {
        let symbol: String    // BTC-USDT
        let pair: String      // BTC/USDT
        let logoName: String
        let price: String
    }

    enum State {
        case loading
        case loaded([Item])
        case error(String)
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private let rest: OKXRESTServiceProtocol
    private var allItems: [Item] = []

    init(rest: OKXRESTServiceProtocol = OKXRESTService()) {
        self.rest = rest
    }

    // MARK: - Load

    func load() {
        Task { [weak self] in
            guard let self else { return }
            state = .loading
            do {
                let tickers = try await rest.fetchAllTickers()
                allItems = tickers
                    .filter { $0.symbol.hasSuffix("-USDT") }
                    .sorted { (Double($0.quoteVolume) ?? 0) > (Double($1.quoteVolume) ?? 0) }
                    .map { makeItem(from: $0) }
                state = .loaded(allItems)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Search

    func search(_ query: String) {
        let q = query.trimmingCharacters(in: .whitespaces).uppercased()
        if q.isEmpty {
            state = .loaded(allItems)
        } else {
            state = .loaded(allItems.filter { $0.pair.contains(q) || $0.symbol.contains(q) })
        }
    }

    // MARK: - Private

    private func makeItem(from ticker: TickerRESTDTO) -> Item {
        let meta = MarketToken.metadata[ticker.symbol]
        let base = meta?.base ?? ticker.symbol.replacingOccurrences(of: "-USDT", with: "")
        let logo = meta?.logo ?? "logo_all"
        return Item(
            symbol: ticker.symbol,
            pair: "\(base)/USDT",
            logoName: logo,
            price: formatPrice(ticker.lastPrice)
        )
    }

    private func formatPrice(_ raw: String) -> String {
        guard let v = Double(raw) else { return raw }
        if v >= 1000 { return String(format: "$%.2f", v) }
        if v >= 1    { return String(format: "$%.4f", v) }
        return "$" + String(format: "%.8f", v)
            .replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
    }
}
