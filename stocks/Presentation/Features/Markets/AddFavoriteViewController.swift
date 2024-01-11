import UIKit
import SnapKit

final class AddFavoriteViewController: UIViewController {

    var onDismiss: (() -> Void)?

    private let viewModel = AddFavoriteViewModel()

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Add Favorite"
        l.font = AppFonts.bold(18)
        l.textColor = .appTextPrimary
        return l
    }()

    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let icon = UIImage(systemName: "xmark", withConfiguration: config)?
            .withTintColor(.appTextSecondary, renderingMode: .alwaysOriginal)
        b.setImage(icon, for: .normal)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        b.layer.cornerRadius = 15
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    private lazy var searchBar: UISearchBar = {
        let s = UISearchBar()
        s.placeholder = "Search pair (BTC, ETH…)"
        s.searchBarStyle = .minimal
        s.tintColor = .appAccent
        s.barTintColor = .clear
        s.backgroundImage = UIImage()
        if let field = s.value(forKey: "searchField") as? UITextField {
            field.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            field.textColor = .appTextPrimary
            field.font = AppFonts.regular(14)
            field.layer.cornerRadius = 12
            field.clipsToBounds = true
            field.attributedPlaceholder = NSAttributedString(
                string: s.placeholder ?? "",
                attributes: [.foregroundColor: UIColor.appTextSecondary]
            )
        }
        s.delegate = self
        return s
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.keyboardDismissMode = .onDrag
        tv.register(AddFavoriteTokenCell.self, forCellReuseIdentifier: AddFavoriteTokenCell.reuseId)
        tv.dataSource = self
        tv.rowHeight = 64
        return tv
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.color = .appAccent
        a.hidesWhenStopped = true
        return a
    }()

    private lazy var emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No results"
        l.font = AppFonts.regular(14)
        l.textColor = .appTextSecondary
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    // MARK: - State

    private var tokens: [SearchToken] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
        setupBindings()
        viewModel.load()
    }

    // MARK: - Setup

    private func setupViews() {
        [titleLabel, closeButton, searchBar,
         tableView, loadingIndicator, emptyLabel].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().inset(24)
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(24)
            make.width.height.equalTo(30)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                break
            case .loading:
                self.loadingIndicator.startAnimating()
                self.emptyLabel.isHidden = true
            case .loaded(let list):
                self.tokens = list
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating()
                self.emptyLabel.isHidden = !list.isEmpty
            case .error:
                self.loadingIndicator.stopAnimating()
                self.emptyLabel.text = "Failed to load"
                self.emptyLabel.isHidden = false
            }
        }
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}

// MARK: - UITableViewDataSource

extension AddFavoriteViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AddFavoriteTokenCell.reuseId,
            for: indexPath
        ) as! AddFavoriteTokenCell
        let token = tokens[indexPath.row]
        cell.configure(with: token)
        cell.onAdd = { [weak self] in
            self?.viewModel.addFavorite(symbol: token.symbol)
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension AddFavoriteViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
