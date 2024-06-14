import Foundation

@MainActor
final class OrderEntryViewModel {

    struct Snapshot {
        let side: OrderSide
        let orderType: OrderType
        let price: Double
        let showsPrice: Bool
        let stopPrice: Double
        let showsStop: Bool
        let quantity: Double
        let total: Double
        let available: Double
        let availableAsset: String
        let canSubmit: Bool
    }

    enum State {
        case loading
        case loaded(Snapshot)
        case error(String)
    }

    var onStateChange: ((State) -> Void)?
    var onOrderPlaced: ((OrderSide) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    let symbol: String
    let side: OrderSide

    private let base: String
    private let quote: String
    private let storage: WalletStorage
    private let orderStorage: OrderStorage

    private var orderType: OrderType = .market
    private var price: Double
    private var stopPrice: Double
    private var quantity: Double = 0

    private let marketPrice: Double
    private let priceStep: Double

    init(
        symbol: String,
        side: OrderSide,
        marketPrice: Double,
        storage: WalletStorage = .shared,
        orderStorage: OrderStorage = .shared
    ) {
        self.symbol       = symbol
        self.side         = side
        self.price        = marketPrice
        self.stopPrice    = marketPrice
        self.marketPrice  = marketPrice
        self.storage      = storage
        self.orderStorage = orderStorage

        let parts = symbol.components(separatedBy: "-")
        self.base  = parts.first ?? symbol
        self.quote = parts.count > 1 ? parts[1] : ""

        self.priceStep = max(marketPrice * 0.001, 0.01)
    }

    func load() {
        emit()
    }

    // MARK: - Edits

    func selectType(_ type: OrderType) {
        guard type != orderType else { return }
        orderType = type
        emit()
    }

    func setPrice(_ value: Double) {
        price = max(0, value)
        emit()
    }

    func stepPrice(up: Bool) {
        price = max(0, price + (up ? priceStep : -priceStep))
        emit()
    }

    func setStopPrice(_ value: Double) {
        stopPrice = max(0, value)
        emit()
    }

    func stepStopPrice(up: Bool) {
        stopPrice = max(0, stopPrice + (up ? priceStep : -priceStep))
        emit()
    }

    func setQuantity(_ value: Double) {
        quantity = max(0, value)
        emit()
    }

    func stepQuantity(up: Bool) {
        quantity = max(0, quantity + (up ? quantityStep : -quantityStep))
        emit()
    }

    func selectPercent(_ percent: Double) {
        let clamped = min(max(percent, 0), 1)
        switch side {
        case .buy:  quantity = effectivePrice > 0 ? (storage.balance * clamped) / effectivePrice : 0
        case .sell: quantity = heldAmount * clamped
        }
        emit()
    }

    // MARK: - Submit

    func submit() {
        guard makeSnapshot().canSubmit else {
            state = .error(insufficientMessage)
            return
        }
        // market orders fill immediately, limit and stop-limit stay pending until the user fills them
        if orderType == .market {
            switch side {
            case .buy:  storage.buy(symbol: symbol, name: base, amount: quantity, cost: total)
            case .sell: storage.sell(symbol: symbol, amount: quantity, proceeds: total)
            }
            orderStorage.add(makeOrder(status: .filled))
        } else {
            orderStorage.add(makeOrder(status: .pending))
        }
        onOrderPlaced?(side)
    }

    private func makeOrder(status: OrderStatus) -> Order {
        Order(
            symbol: symbol,
            side: side,
            type: orderType,
            price: effectivePrice,
            quantity: quantity,
            total: total,
            status: status
        )
    }

    // MARK: - Private

    private var effectivePrice: Double {
        orderType == .market ? marketPrice : price
    }

    private var total: Double { effectivePrice * quantity }

    private var quantityStep: Double {
        effectivePrice > 0 ? 1 / effectivePrice : 0.0001
    }

    private var heldAmount: Double {
        storage.holdings.first { $0.symbol == symbol }?.amount ?? 0
    }

    private var available: Double {
        side == .buy ? storage.balance : heldAmount
    }

    private var availableAsset: String {
        side == .buy ? quote : base
    }

    private var insufficientMessage: String {
        side == .buy ? "Not enough \(quote) balance" : "Not enough \(base) to sell"
    }

    private func makeSnapshot() -> Snapshot {
        var valid: Bool
        switch side {
        case .buy:  valid = quantity > 0 && effectivePrice > 0 && total <= storage.balance
        case .sell: valid = quantity > 0 && effectivePrice > 0 && quantity <= heldAmount
        }
        if orderType == .stopLimit { valid = valid && stopPrice > 0 }

        return Snapshot(
            side: side,
            orderType: orderType,
            price: effectivePrice,
            showsPrice: orderType != .market,
            stopPrice: stopPrice,
            showsStop: orderType == .stopLimit,
            quantity: quantity,
            total: total,
            available: available,
            availableAsset: availableAsset,
            canSubmit: valid
        )
    }

    private func emit() {
        state = .loaded(makeSnapshot())
    }
}
