import UIKit
import SnapKit

final class PairPickerViewController: UIViewController {

    var onSelectPair: ((String) -> Void)?

    private let viewModel: PairPickerViewModel
    private var items: [PairPickerViewModel.Item] = []

    init(viewModel: PairPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Select Pair"
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
        s.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        s.searchTextField.textColor = .appTextPrimary
        s.searchTextField.font = AppFonts.regular(14)
        s.searchTextField.layer.cornerRadius = 12
        s.searchTextField.clipsToBounds = true
        s.searchTextField.attributedPlaceholder = NSAttributedString(
            string: s.placeholder ?? "",
            attributes: [.foregroundColor: UIColor.appTextSecondary]
        )
        s.delegate = self
        return s
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.keyboardDismissMode = .onDrag
        tv.register(PairPickerCell.self, forCellReuseIdentifier: PairPickerCell.reuseId)
        tv.dataSource = self
        tv.delegate = self
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
        loadingIndicator.snp.makeConstraints { $0.center.equalTo(tableView) }
        emptyLabel.snp.makeConstraints { $0.center.equalTo(tableView) }
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.loadingIndicator.startAnimating()
                self.emptyLabel.isHidden = true
            case .loaded(let list):
                self.items = list
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
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PairPickerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PairPickerCell.reuseId,
            for: indexPath
        ) as! PairPickerCell
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PairPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let symbol = items[indexPath.row].symbol
        dismiss(animated: true) { [weak self] in
            self?.onSelectPair?(symbol)
        }
    }
}

// MARK: - UISearchBarDelegate

extension PairPickerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Cell

private final class PairPickerCell: UITableViewCell {

    static let reuseId = "PairPickerCell"

    private lazy var logoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var pairLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(14)
        l.textColor = .appTextPrimary
        return l
    }()

    private lazy var priceLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(12)
        l.textColor = .appTextSecondary
        return l
    }()

    private lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        [logoView, pairLabel, priceLabel, separator].forEach { contentView.addSubview($0) }

        logoView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        pairLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoView.snp.trailing).offset(13)
            make.top.equalTo(logoView).offset(4)
        }
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(pairLabel)
            make.top.equalTo(pairLabel.snp.bottom).offset(4)
        }
        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: PairPickerViewModel.Item) {
        logoView.image = UIImage(named: item.logoName)
        pairLabel.text = item.pair
        priceLabel.text = item.price
    }
}
