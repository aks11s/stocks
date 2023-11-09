import UIKit

final class TabBarController: UITabBarController {

    private(set) var coordinator: Coordinator
    var onLogout: (() -> Void)?

    // MARK: - Init

    required init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Tab view controllers

    private lazy var homeVC: UIViewController = {
        let vc = HomeViewController()
        vc.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "tab_home"),
            tag: 0
        )
        return vc
    }()

    private lazy var marketsVC: UIViewController = {
        let vc = MarketsViewController()
        vc.tabBarItem = UITabBarItem(
            title: "Markets",
            image: UIImage(named: "tab_markets"),
            tag: 1
        )
        return vc
    }()

    private lazy var walletVC: UIViewController = {
        let vc = WalletViewController()
        vc.tabBarItem = UITabBarItem(
            title: "Wallet",
            image: UIImage(named: "tab_wallet"),
            tag: 2
        )
        return vc
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        viewControllers = [homeVC, marketsVC, walletVC]
    }

    // MARK: - Appearance

    private func setupAppearance() {
        // Colors
        tabBar.tintColor = .appAccent
        tabBar.unselectedItemTintColor = .appTextSecondary
        tabBar.barTintColor = .appBackground
        tabBar.isTranslucent = false

        // Remove the default hairline separator
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBackground
        appearance.shadowColor = .clear

        // Label font — Neue Montreal 12pt
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: AppFonts.regular(12)
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = labelAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = labelAttrs

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
