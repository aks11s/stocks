import UIKit
import SnapKit

final class WalletViewController: UIViewController {

    private let viewModel = WalletViewModel()

    // MARK: - Header

    private lazy var headerView = HomeHeaderView()

    // MARK: - Balance views

    private let balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Balance"
        label.font = AppFonts.regular(14)
        label.textColor = .appTextSecondary
        return label
    }()

    private let balanceAmountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.bold(34)
        label.textColor = .appTextPrimary
        return label
    }()

    private let balanceFiatLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regular(14)
        label.textColor = .appTextSecondary
        return label
    }()

    private lazy var visibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .appTextSecondary
        button.setImage(UIImage(named: "unview"), for: .normal)
        return button
    }()

    // MARK: - Action tabs

    private lazy var depositButton  = makeTabButton(title: "Deposit",  isActive: true)
    private lazy var withdrawButton = makeTabButton(title: "Withdraw", isActive: false)
    private lazy var transferButton = makeTabButton(title: "Transfer", isActive: false)

    private let tabsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.s
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Holdings table

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        return tv
    }()

    private var holdings: [HoldingEntry] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupHeader()
        setupTableView()
        setupLayout()
        bindViewModel()
        depositButton.addTarget(self, action: #selector(depositTapped), for: .touchUpInside)
        visibilityButton.addTarget(self, action: #selector(visibilityTapped), for: .touchUpInside)
        viewModel.load()
    }

    // MARK: - Setup

    private func setupHeader() {
        headerView.onAvatarTap = { [weak self] in
            let profile = ProfileViewController()
            profile.modalPresentationStyle = .fullScreen
            self?.present(profile, animated: true)
        }
        headerView.onScanTap  = { [weak self] in self?.openDev() }
        headerView.onNotifTap = { [weak self] in self?.openDev() }
    }

    private func setupTableView() {
        tableView.register(WalletHoldingCell.self, forCellReuseIdentifier: WalletHoldingCell.reuseID)
        tableView.dataSource = self
    }

    private func setupLayout() {
        [headerView, balanceTitleLabel, visibilityButton,
         balanceAmountLabel, balanceFiatLabel, tabsStackView, tableView].forEach {
            view.addSubview($0)
        }

        tabsStackView.addArrangedSubview(depositButton)
        tabsStackView.addArrangedSubview(withdrawButton)
        tabsStackView.addArrangedSubview(transferButton)

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(51)
        }

        balanceTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.l)
            make.leading.equalToSuperview().inset(Spacing.l)
        }

        visibilityButton.snp.makeConstraints { make in
            make.centerY.equalTo(balanceTitleLabel)
            make.trailing.equalToSuperview().inset(Spacing.l)
            make.width.height.equalTo(28)
        }

        balanceAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceTitleLabel.snp.bottom).offset(Spacing.s)
            make.leading.equalToSuperview().inset(Spacing.l)
        }

        balanceFiatLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceAmountLabel.snp.bottom).offset(Spacing.xs)
            make.leading.equalToSuperview().inset(Spacing.l)
        }

        tabsStackView.snp.makeConstraints { make in
            make.top.equalTo(balanceFiatLabel.snp.bottom).offset(Spacing.l)
            make.leading.trailing.equalToSuperview().inset(Spacing.l)
            make.height.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(tabsStackView.snp.bottom).offset(Spacing.m)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            if case .loaded(let balance, let holdings, let isHidden) = state {
                self.balanceAmountLabel.text = isHidden ? "••••••" : String(format: "%.2f", balance)
                self.balanceFiatLabel.text   = isHidden ? "••••••" : String(format: "$%.2f", balance)
                self.visibilityButton.setImage(UIImage(named: isHidden ? "view" : "unview"), for: .normal)
                self.holdings = holdings
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Actions

    @objc private func visibilityTapped() {
        viewModel.toggleBalanceVisibility()
    }

    @objc private func depositTapped() {
        let vc = DepositViewController()
        vc.onDeposit = { [weak self] amount in
            self?.viewModel.deposit(amount: amount)
        }
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }

    private func openDev() {
        navigationController?.pushViewController(UnderDevelopmentViewController(), animated: true)
    }

    // MARK: - Helpers

    private func makeTabButton(title: String, isActive: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFonts.medium(14)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        if isActive {
            button.backgroundColor = .appAccent
            button.setTitleColor(.appButtonLabel, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.appTextSecondary, for: .normal)
        }
        return button
    }
}

// MARK: - UITableViewDataSource

extension WalletViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        holdings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletHoldingCell.reuseID, for: indexPath) as! WalletHoldingCell
        cell.configure(with: holdings[indexPath.row])
        return cell
    }
}
