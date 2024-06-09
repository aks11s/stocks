import UIKit
import SnapKit

final class OrdersViewController: UIViewController {

    private let viewModel: OrdersViewModel

    private var open: [Order] = []
    private var history: [Order] = []

    private enum Section: Int, CaseIterable {
        case open, history

        var title: String {
            switch self {
            case .open:    return "Open Orders"
            case .history: return "History"
            }
        }
    }

    // MARK: - Views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Orders"
        label.font = AppFonts.bold(24)
        label.textColor = .appTextPrimary
        return label
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        return tv
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No orders yet"
        label.font = AppFonts.regular(15)
        label.textColor = .appTextSecondary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Init

    init(viewModel: OrdersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupTableView()
        setupLayout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupLayout() {
        [titleLabel, tableView, emptyLabel].forEach { view.addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.m)
            make.leading.equalToSuperview().inset(Spacing.l)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.m)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loaded(let open, let history):
                self.open = open
                self.history = history
                self.emptyLabel.isHidden = !(open.isEmpty && history.isEmpty)
                self.tableView.reloadData()
            case .error(let message):
                self.presentError(message)
            case .loading:
                break
            }
        }
    }

    // MARK: - Helpers

    private func orders(in section: Section) -> [Order] {
        section == .open ? open : history
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension OrdersViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Section(rawValue: section).map { orders(in: $0).count } ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseID, for: indexPath) as! OrderCell
        if let section = Section(rawValue: indexPath.section) {
            cell.configure(with: orders(in: section)[indexPath.row])
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension OrdersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section), !orders(in: section).isEmpty else { return nil }

        let container = UIView()
        let label = UILabel()
        label.text = section.title
        label.font = AppFonts.medium(14)
        label.textColor = .appTextSecondary
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Spacing.l)
            make.centerY.equalToSuperview()
        }
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section), !orders(in: section).isEmpty else { return .leastNormalMagnitude }
        return 36
    }

    // tap a pending order to fill it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard Section(rawValue: indexPath.section) == .open else { return }
        viewModel.fill(order: open[indexPath.row])
    }

    // swipe to cancel open orders only
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard Section(rawValue: indexPath.section) == .open else { return nil }

        let cancel = UIContextualAction(style: .destructive, title: "Cancel") { [weak self] _, _, done in
            guard let self else { return done(false) }
            self.viewModel.cancel(order: self.open[indexPath.row])
            done(true)
        }
        cancel.backgroundColor = .appRed
        return UISwipeActionsConfiguration(actions: [cancel])
    }
}
