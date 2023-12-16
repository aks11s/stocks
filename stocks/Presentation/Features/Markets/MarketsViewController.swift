import UIKit
import SnapKit

final class MarketsViewController: UIViewController {

    private let viewModel = MarketViewModel()

    // MARK: - Header subviews

    private lazy var headerView: UIView = {
        let v = UIView()
        v.backgroundColor = .appBackground
        // shadow matching Figma: 0 12 16 rgba(22,28,34,0.5)
        v.layer.shadowColor = UIColor(red: 22/255, green: 28/255, blue: 34/255, alpha: 0.5).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 12)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 1
        return v
    }()

    private lazy var avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = .appAccent
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private lazy var avatarLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(14)
        l.textColor = .appBackground
        l.textAlignment = .center
        l.text = ProfileStorage.shared.username?.first.map { String($0).uppercased() } ?? "U"
        return l
    }()

    private lazy var searchButton: UIButton = makeHeaderIcon("icon_search")
    private lazy var scanButton: UIButton   = makeHeaderIcon("icon_scan")
    private lazy var notifButton: UIButton  = makeHeaderIcon("icon_notif")

    // MARK: - Content subviews

    private lazy var filterTabs = MarketFilterTabsView()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.register(MarketTokenCell.self, forCellReuseIdentifier: MarketTokenCell.reuseId)
        tv.dataSource = self
        tv.rowHeight = 81
        return tv
    }()

    private lazy var addFavoriteButton: UIButton = {
        let b = UIButton(type: .system)

        // Dashed border layer
        let dash = CAShapeLayer()
        dash.strokeColor = UIColor(red: 62/255, green: 71/255, blue: 79/255, alpha: 0.5).cgColor
        dash.fillColor = UIColor.clear.cgColor
        dash.lineWidth = 2
        dash.lineDashPattern = [4, 5]
        b.layer.addSublayer(dash)
        b.layer.cornerRadius = 12
        b.clipsToBounds = false

        // Store the dash layer so we can update its path on layout
        b.layer.setValue(dash, forKey: "dashLayer")

        b.backgroundColor = UIColor(red: 62/255, green: 71/255, blue: 79/255, alpha: 0.1)
        b.setTitle("  Add Favorite", for: .normal)
        b.setTitleColor(.appTextSecondary, for: .normal)
        b.titleLabel?.font = AppFonts.regular(18)
        b.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        b.tintColor = .appTextSecondary
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update dashed border path after layout
        if let dash = addFavoriteButton.layer.value(forKey: "dashLayer") as? CAShapeLayer {
            dash.path = UIBezierPath(roundedRect: addFavoriteButton.bounds, cornerRadius: 12).cgPath
        }
    }

    // MARK: - Setup

    private func setupViews() {
        // Header
        view.addSubview(headerView)
        headerView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        headerView.addSubview(searchButton)
        headerView.addSubview(scanButton)
        headerView.addSubview(notifButton)

        // Content
        view.addSubview(filterTabs)
        view.addSubview(tableView)
        view.addSubview(addFavoriteButton)
    }

    private func setupLayout() {
        // Header: 414×95 at top
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(95)
        }

        // Avatar: 36×36 at x=24, y=41 (Figma)
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(41)
            make.width.height.equalTo(36)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // Icons: 44×44, right side — Scan x=304, Search x=252, Notif x=356
        notifButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)   // 414-356=58 → inset 14 (44pt button)
            make.top.equalToSuperview().inset(37)
            make.width.height.equalTo(44)
        }

        scanButton.snp.makeConstraints { make in
            make.trailing.equalTo(notifButton.snp.leading)
            make.top.equalTo(notifButton)
            make.width.height.equalTo(44)
        }

        searchButton.snp.makeConstraints { make in
            make.trailing.equalTo(scanButton.snp.leading)
            make.top.equalTo(notifButton)
            make.width.height.equalTo(44)
        }

        // Filter tabs: 366×46 at x=24, y=115
        filterTabs.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.height.equalTo(46)
        }

        // Table: below filter tabs, above Add Favorite button
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(filterTabs.snp.bottom).offset(10)
            make.bottom.equalTo(addFavoriteButton.snp.top).offset(-12)
        }

        // Add Favorite: 366×60, y=677 from screen top
        addFavoriteButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
        }
    }

    // MARK: - Helpers

    private func makeHeaderIcon(_ name: String) -> UIButton {
        let b = UIButton(type: .system)
        let img = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
        b.setImage(img, for: .normal)
        b.tintColor = .white
        return b
    }
}

// MARK: - UITableViewDataSource

extension MarketsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MarketTokenCell.reuseId, for: indexPath) as! MarketTokenCell
        cell.configure(with: viewModel.tokens[indexPath.row])
        return cell
    }
}
