import UIKit

final class DepositViewController: UIViewController {

    var onDeposit: ((Double) -> Void)?

    // MARK: - Views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Deposit"
        label.font = AppFonts.bold(22)
        label.textColor = .appTextPrimary
        return label
    }()

    private let amountField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter amount"
        field.keyboardType = .decimalPad
        field.font = AppFonts.regular(16)
        field.textColor = .appTextPrimary
        field.backgroundColor = .appSurfaceCard
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.m, height: 0))
        field.leftViewMode = .always
        return field
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.titleLabel?.font = AppFonts.medium(16)
        button.backgroundColor = .appAccent
        button.setTitleColor(.appButtonLabel, for: .normal)
        button.layer.cornerRadius = 14
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appSurface
        setupLayout()
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    // MARK: - Layout

    private func setupLayout() {
        [titleLabel, amountField, confirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Spacing.xl),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),

            amountField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xl),
            amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),
            amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.l),
            amountField.heightAnchor.constraint(equalToConstant: 52),

            confirmButton.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: Spacing.l),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.l),
            confirmButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // MARK: - Actions

    @objc private func confirmTapped() {
        guard let text = amountField.text,
              let amount = Double(text),
              amount > 0 else { return }
        onDeposit?(amount)
        dismiss(animated: true)
    }
}
