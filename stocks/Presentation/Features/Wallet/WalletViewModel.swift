import Foundation

@MainActor
final class WalletViewModel {

    enum State {
        case loading
        case loaded(balance: Double, holdings: [HoldingEntry], isBalanceHidden: Bool)
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private let storage = WalletStorage.shared
    private(set) var isBalanceHidden = false

    func load() {
        state = .loaded(balance: storage.balance, holdings: storage.holdings, isBalanceHidden: isBalanceHidden)
    }

    func deposit(amount: Double) {
        storage.balance += amount
        state = .loaded(balance: storage.balance, holdings: storage.holdings, isBalanceHidden: isBalanceHidden)
    }

    func toggleBalanceVisibility() {
        isBalanceHidden.toggle()
        state = .loaded(balance: storage.balance, holdings: storage.holdings, isBalanceHidden: isBalanceHidden)
    }
}
