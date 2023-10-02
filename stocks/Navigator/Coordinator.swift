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
        tabBar.onLogout = { [weak self] in self?.logout() }
        navigationController.setViewControllers([tabBar], animated: true)
    }

    private func logout() {
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        showAuth(animated: true)
    }
}
