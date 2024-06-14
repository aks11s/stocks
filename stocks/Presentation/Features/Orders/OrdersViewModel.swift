import Foundation

@MainActor
final class OrdersViewModel {

    enum State {
        case loading
        case loaded(open: [Order], history: [Order])
        case error(String)
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private let storage: WalletStorage
    private let orderStorage: OrderStorage

    init(storage: WalletStorage = .shared, orderStorage: OrderStorage = .shared) {
        self.storage      = storage
        self.orderStorage = orderStorage
    }

    func load() {
        let all = orderStorage.all
        let open = all.filter { $0.status == .pending }
        let history = all.filter { $0.status != .pending }
        state = .loaded(open: open, history: history)
    }

    // MARK: - Actions

    func cancel(order: Order) {
        orderStorage.cancel(id: order.id)
        load()
    }

    func fill(order: Order) {
        let base = order.symbol.components(separatedBy: "-").first ?? order.symbol

        switch order.side {
        case .buy:
            guard order.total <= storage.balance else {
                state = .error("Not enough balance to fill this order")
                return
            }
            storage.buy(symbol: order.symbol, name: base, amount: order.quantity, cost: order.total)
        case .sell:
            let held = storage.holdings.first { $0.symbol == order.symbol }?.amount ?? 0
            guard order.quantity <= held else {
                state = .error("Not enough \(base) to fill this order")
                return
            }
            storage.sell(symbol: order.symbol, amount: order.quantity, proceeds: order.total)
        }

        orderStorage.fill(id: order.id)
        load()
    }
}
