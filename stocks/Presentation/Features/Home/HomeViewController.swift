import UIKit
import SnapKit

final class HomeViewController: UIViewController {

    // MARK: - Subviews

    private lazy var headerView = HomeHeaderView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(headerView)
    }

    private func setupLayout() {
        // Header extends behind the status bar and stops 51pt below the safe area top
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(51)
        }
    }
}
