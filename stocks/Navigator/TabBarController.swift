import Foundation
import UIKit


class TabBarController: UITabBarController{
    private (set) var coordinator: Coordinator

    //MARK: - Init

    required init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controllers

    private lazy var homeVC: UIViewController = {
        let viewController = ViewController()
        viewController.tabBarItem.title = "Главная"
        viewController.tabBarItem.image = UIImage(systemName: "house")
        return viewController
    }()
 
    

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        setupControllers()
    }

    // MARK: - Setups

    private func setupInterface() {
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .black
        tabBar.backgroundColor = .white
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowRadius = 2
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    private func setupControllers() {
        

        viewControllers = [homeVC ]
        
    }
}


