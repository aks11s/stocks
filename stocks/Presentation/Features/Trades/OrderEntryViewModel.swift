import Foundation

@MainActor
final class OrderEntryViewModel {

    struct Snapshot {
        let side: OrderSide
        let orderType: OrderType
        let price: Double
        // market orders execute at the live price, so the field is hidden
        let showsPrice: Bool
        // trigger price, only meaningful for stop-limit orders
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

    private var orderType: OrderType = .market
    // user-entered limit price, used for limit/stop-limit only
    private var price: Double
    // trigger price that arms the limit order, stop-limit only
    private var stopPrice: Double
    private var quantity: Double = 0

    // live price from the trade screen, used as-is for market orders
    private let marketPrice: Double
    private let priceStep: Double

    init(symbol: String, side: OrderSide, marketPrice: Double, storage: WalletStorage = .shared) {
        self.symbol      = symbol
        self.side        = side
        self.price       = marketPrice
        self.stopPrice   = marketPrice
        self.marketPrice = marketPrice
        self.storage     = storage

        let parts = symbol.components(separatedBy: "-")
        self.base  = parts.first ?? symbol
        self.quote = parts.count > 1 ? parts[1] : ""

        // nudge price by ~0.1% per tap, with a floor for cheap coins
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

    // percent of what you can spend (buy) or what you hold (sell)
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
        switch side {
        case .buy:  storage.buy(symbol: symbol, name: base, amount: quantity, cost: total)
        case .sell: storage.sell(symbol: symbol, amount: quantity, proceeds: total)
        }
        onOrderPlaced?(side)
    }

    // MARK: - Private

    // limit orders fill at the entered price, market orders at the live price
    private var effectivePrice: Double {
        orderType == .market ? marketPrice : price
    }

    private var total: Double { effectivePrice * quantity }

    // one tap ≈ one quote unit ($1) worth of the coin
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
        // stop-limit also needs a trigger price to arm the order
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
