import UIKit

final class WalletViewController: UIViewController {

    private let viewModel = WalletViewModel()

    // MARK: - Header views

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupLayout()
        bindViewModel()
        viewModel.load()
    }

    // MARK: - Layout

    private func setupLayout() {
        [balanceTitleLabel, balanceAmountLabel, balanceFiatLabel, tabsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        tabsStackView.addArrangedSubview(depositButton)
        tabsStackView.addArrangedSubview(withdrawButton)
        tabsStackView.addArrangedSubview(transferButton)

        NSLayoutConstraint.activate([
            balanceTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.l),
            balanceTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),

            balanceAmountLabel.topAnchor.constraint(equalTo: balanceTitleLabel.bottomAnchor, constant: Spacing.s),
            balanceAmountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),

            balanceFiatLabel.topAnchor.constraint(equalTo: balanceAmountLabel.bottomAnchor, constant: Spacing.xs),
            balanceFiatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),

            tabsStackView.topAnchor.constraint(equalTo: balanceFiatLabel.bottomAnchor, constant: Spacing.l),
            tabsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),
            tabsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.l),
            tabsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            if case .loaded(let balance, _) = state {
                self.balanceAmountLabel.text = String(format: "%.2f", balance)
                self.balanceFiatLabel.text = String(format: "$%.2f", balance)
            }
        }
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
