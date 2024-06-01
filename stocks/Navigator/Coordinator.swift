import UIKit

protocol Coordinator: AnyObject {
    func start()
}

final class MainCoordinator: Coordinator {

    let navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }()

    // MARK: - Entry point

    func start() {
        let defaults = UserDefaults.standard
        let hasSeenOnboarding = defaults.bool(forKey: "hasSeenOnboarding")
        let isAuthenticated   = defaults.bool(forKey: "isAuthenticated")

        if !hasSeenOnboarding {
            showOnboarding()
        } else if !isAuthenticated {
            showAuth(animated: false)
        } else {
            showMainApp()
        }
    }

    // MARK: - Navigation

    private func showOnboarding() {
        let vc = OnboardingViewController()
        vc.onFinish = { [weak self] in
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            self?.showAuth(animated: true)
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showAuth(animated: Bool) {
        let vm = AuthViewModel()
        let vc = AuthViewController(viewModel: vm)
        vc.onFinish = { [weak self] in self?.showMainApp() }
        navigationController.setViewControllers([vc], animated: animated)
    }

    private func showMainApp() {
        let tabBar = TabBarController(coordinator: self)
        tabBar.onLogout    = { [weak self] in self?.logout() }
        tabBar.onShowTrade = { [weak self] symbol in
            Task { @MainActor [weak self] in self?.showTrade(symbol: symbol) }
        }
        navigationController.setViewControllers([tabBar], animated: true)
    }

    @MainActor func showTrade(symbol: String) {
        let vm = TradeViewModel(symbol: symbol)
        let vc = TradeViewController(viewModel: vm)
        vc.onBack = { [weak self] in self?.navigationController.popToRootViewController(animated: true) }
        vc.onShowPairPicker = { [weak self] in self?.showPairPicker() }
        vc.onBuy = { [weak self] price in
            self?.showOrderEntry(symbol: symbol, side: .buy, marketPrice: price)
        }
        vc.onSell = { [weak self] price in
            self?.showOrderEntry(symbol: symbol, side: .sell, marketPrice: price)
        }

        var stack = navigationController.viewControllers
        if stack.last is TradeViewController {
            stack[stack.count - 1] = vc
            navigationController.setViewControllers(stack, animated: false)
        } else {
            navigationController.pushViewController(vc, animated: true)
        }
    }

    @MainActor private func showOrderEntry(symbol: String, side: OrderSide, marketPrice: Double) {
        let vm = OrderEntryViewModel(symbol: symbol, side: side, marketPrice: marketPrice)
        let vc = OrderEntryViewController(viewModel: vm)
        vm.onOrderPlaced = { [weak vc] _ in vc?.dismiss(animated: true) }
        navigationController.present(vc, animated: true)
    }

    @MainActor private func showPairPicker() {
        let vm = PairPickerViewModel()
        let picker = PairPickerViewController(viewModel: vm)
        picker.onSelectPair = { [weak self] symbol in
            self?.showTrade(symbol: symbol)
        }
        navigationController.present(picker, animated: true)
    }

    private func logout() {
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        showAuth(animated: true)
    }
}
