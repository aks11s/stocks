import UIKit
import SnapKit

final class MarketsViewController: UIViewController {

    private let viewModel = MarketViewModel()

    // MARK: - Header

    private lazy var headerView = HomeHeaderView()

    // MARK: - Content

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.register(MarketTokenCell.self, forCellReuseIdentifier: MarketTokenCell.reuseId)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = 81
        // Pull-to-refresh
        tv.refreshControl = refreshControl
        return tv
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .appAccent
        r.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return r
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.color = .appAccent
        a.hidesWhenStopped = true
        return a
    }()

    private lazy var errorLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appTextSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    private lazy var addFavoriteButton: UIButton = {
        let b = UIButton(type: .system)
        let dash = CAShapeLayer()
        dash.strokeColor = UIColor(red: 62/255, green: 71/255, blue: 79/255, alpha: 0.5).cgColor
        dash.fillColor = UIColor.clear.cgColor
        dash.lineWidth = 2
        dash.lineDashPattern = [4, 5]
        b.layer.addSublayer(dash)
        b.layer.setValue(dash, forKey: "dashLayer")
        b.backgroundColor = UIColor(red: 62/255, green: 71/255, blue: 79/255, alpha: 0.1)
        b.layer.cornerRadius = 12
        b.setTitle("  Add Favorite", for: .normal)
        b.setTitleColor(.appTextSecondary, for: .normal)
        b.titleLabel?.font = AppFonts.regular(18)
        b.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        b.tintColor = .appTextSecondary
        b.addTarget(self, action: #selector(addFavoriteTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - State

    private var tokens: [MarketToken] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
        bindViewModel()
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // tableFooterView needs an explicit frame — Auto Layout doesn't apply inside it
        if let footer = tableView.tableFooterView {
            let width = tableView.bounds.width
            let buttonHeight: CGFloat = 60
            let padding: CGFloat = 16
            let totalHeight = buttonHeight + padding * 2
            addFavoriteButton.frame = CGRect(x: 0, y: padding, width: width, height: buttonHeight)
            if footer.frame.height != totalHeight {
                footer.frame = CGRect(x: 0, y: 0, width: width, height: totalHeight)
                tableView.tableFooterView = footer
            }
        }
        if let dash = addFavoriteButton.layer.value(forKey: "dashLayer") as? CAShapeLayer {
            dash.path = UIBezierPath(roundedRect: addFavoriteButton.bounds, cornerRadius: 12).cgPath
        }
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)

        // Button lives inside the table footer so it scrolls with the list
        let footer = UIView()
        footer.addSubview(addFavoriteButton)
        tableView.tableFooterView = footer
    }

    private func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(51)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }

        errorLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.loadingIndicator.startAnimating()
                self.errorLabel.isHidden = true
            case .loaded(let list):
                self.tokens = list
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.errorLabel.isHidden = true
            case .error(let msg):
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.errorLabel.text = msg
                self.errorLabel.isHidden = false
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        viewModel.reload()
    }

    @objc private func addFavoriteTapped() {
        let vc = AddFavoriteViewController()
        // reload when closed via the X button
        vc.onDismiss = { [weak self] in
            self?.viewModel.reload()
        }
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        // reload when dismissed by swipe-down gesture
        vc.presentationController?.delegate = self
        present(vc, animated: true)
    }

}

// MARK: - UIAdaptivePresentationControllerDelegate

extension MarketsViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.reload()
    }
}

// MARK: - UITableViewDataSource

extension MarketsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MarketTokenCell.reuseId, for: indexPath) as! MarketTokenCell
        cell.configure(with: tokens[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MarketsViewController: UITableViewDelegate {

    // Swipe-to-delete removes token from favorites
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, done in
            self?.viewModel.removeFavorite(at: indexPath.row)
            done(true)
        }
        delete.image = makeTrashIcon()
        // match screen background so only the icon bubble is visible
        delete.backgroundColor = .appBackground
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func makeTrashIcon() -> UIImage {
        let size = CGSize(width: 52, height: 52)
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.appRed.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 14).fill()
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            if let icon = UIImage(systemName: "trash", withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                let origin = CGPoint(x: (size.width - icon.size.width) / 2,
                                     y: (size.height - icon.size.height) / 2)
                icon.draw(at: origin)
            }
        }
    }
}
