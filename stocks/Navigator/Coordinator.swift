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
        vc.onFinish = { [weak self] in self?.showMainApp() }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showMainApp() {
        let tabBar = TabBarController(coordinator: self)
        navigationController.setViewControllers([tabBar], animated: true)
    }
}
