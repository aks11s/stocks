import Foundation

@MainActor
final class WalletViewModel {

    enum State {
        case loading
        case loaded(balance: Double, holdings: [HoldingEntry])
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private let storage = WalletStorage.shared

    func load() {
        state = .loaded(balance: storage.balance, holdings: storage.holdings)
    }

    func deposit(amount: Double) {
        storage.balance += amount
        state = .loaded(balance: storage.balance, holdings: storage.holdings)
    }
}
