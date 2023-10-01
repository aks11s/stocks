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

    func start() {
        let vc = OnboardingViewController()
        vc.onFinish = { [weak self] in self?.showAuth() }
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - Navigation

    private func showAuth() {
        let vm = AuthViewModel()
        let vc = AuthViewController(viewModel: vm)
        vc.onFinish = { [weak self] in self?.showMainApp() }
        navigationController.setViewControllers([vc], animated: true)
    }

    private func showMainApp() {
        let tabBar = TabBarController(coordinator: self)
        tabBar.onLogout = { [weak self] in self?.logout() }
        navigationController.setViewControllers([tabBar], animated: true)
    }

    private func logout() {
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        showAuth()
    }
}
