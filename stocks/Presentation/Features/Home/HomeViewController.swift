import UIKit
import SnapKit

final class HomeViewController: UIViewController {

    // MARK: - Subviews

    private lazy var headerView = HomeHeaderView()
    private lazy var quickActionsView = QuickActionsView()

    // White scrollable area below the dark section
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
    }

    // MARK: - Setup

    private func setupViews() {
        // Header and quick actions pinned directly to view — fixed, no scroll
        [headerView, quickActionsView].forEach { view.addSubview($0) }

        // Everything else scrolls
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func setupLayout() {
        // Header: top of view → extends behind status bar; height = safeArea.top + 51pt
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(51)
        }

        // Quick actions: fixed below header, 168pt tall
        quickActionsView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(168)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(quickActionsView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            // Bottom pinned to safeArea so content doesn't hide behind tab bar
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }
}
