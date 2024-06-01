import UIKit
import SnapKit

final class OrderEntryViewController: UIViewController {

    private let viewModel: OrderEntryViewModel

    private let base: String
    private let quote: String

    // which field the user is typing in, so live state updates don't fight the cursor
    private enum EditingField { case price, quantity }
    private var editingField: EditingField?

    // MARK: - Init

    init(viewModel: OrderEntryViewModel) {
        self.viewModel = viewModel

        let parts = viewModel.symbol.components(separatedBy: "-")
        self.base  = parts.first ?? viewModel.symbol
        self.quote = parts.count > 1 ? parts[1] : ""

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "\(viewModel.side == .buy ? "Buy" : "Sell") \(base)"
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
        b.backgroundColor = .appSurfaceCard
        b.layer.cornerRadius = 15
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    private let typeSelector: UIView = {
        let v = UIView()
        v.backgroundColor = .appSurfaceCard
        v.layer.cornerRadius = 12
        return v
    }()

    private var typeButtons: [(type: OrderType, button: UIButton)] = []

    private let typeOptions: [(label: String, value: OrderType)] = [
        ("Limit", .limit),
        ("Market", .market),
        ("Stop-Limit", .stopLimit)
    ]

    private lazy var priceField = OrderStepperFieldView(title: "Price (\(quote))")
    private lazy var quantityField = OrderStepperFieldView(title: "Amount (\(base))")

    private let percentRow = UIStackView()
    private var percentButtons: [UIButton] = []
    private let percents: [Double] = [0.25, 0.5, 0.75, 1.0]

    private lazy var availableLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(13)
        l.textColor = .appTextSecondary
        return l
    }()

    private lazy var totalLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.medium(15)
        l.textColor = .appTextPrimary
        return l
    }()

    private lazy var errorLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(13)
        l.textColor = .appRed
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    private lazy var submitButton: UIButton = {
        let b = UIButton()
        b.setTitle("\(viewModel.side == .buy ? "Buy" : "Sell") \(base)", for: .normal)
        b.setTitleColor(.appButtonLabel, for: .normal)
        b.titleLabel?.font = AppFonts.medium(16)
        b.backgroundColor = viewModel.side == .buy ? .appAccent : .appRed
        b.layer.cornerRadius = 12
        b.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return b
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
        [titleLabel, closeButton, typeSelector,
         priceField, quantityField, percentRow,
         availableLabel, totalLabel, errorLabel, submitButton].forEach { view.addSubview($0) }

        configureTypeSelector()
        configurePercentRow()
        configureFieldCallbacks()
    }

    private func configureTypeSelector() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        typeSelector.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }

        for option in typeOptions {
            let b = UIButton()
            b.setTitle(option.label, for: .normal)
            b.titleLabel?.font = AppFonts.medium(13)
            b.layer.cornerRadius = 8
            b.addTarget(self, action: #selector(typeTapped(_:)), for: .touchUpInside)
            b.tag = typeButtons.count
            stack.addArrangedSubview(b)
            typeButtons.append((option.value, b))
        }
    }

    private func configurePercentRow() {
        percentRow.axis = .horizontal
        percentRow.distribution = .fillEqually
        percentRow.spacing = Spacing.s

        for (index, percent) in percents.enumerated() {
            let b = UIButton()
            b.setTitle("\(Int(percent * 100))%", for: .normal)
            b.setTitleColor(.appTextSecondary, for: .normal)
            b.titleLabel?.font = AppFonts.regular(13)
            b.backgroundColor = .appSurfaceCard
            b.layer.cornerRadius = 8
            b.tag = index
            b.addTarget(self, action: #selector(percentTapped(_:)), for: .touchUpInside)
            percentRow.addArrangedSubview(b)
            percentButtons.append(b)
        }
    }

    private func configureFieldCallbacks() {
        priceField.onStep = { [weak self] up in self?.viewModel.stepPrice(up: up) }
        priceField.onValueEdited = { [weak self] value in
            guard let self else { return }
            self.editingField = .price
            self.viewModel.setPrice(value)
            self.editingField = nil
        }

        quantityField.onStep = { [weak self] up in self?.viewModel.stepQuantity(up: up) }
        quantityField.onValueEdited = { [weak self] value in
            guard let self else { return }
            self.editingField = .quantity
            self.viewModel.setQuantity(value)
            self.editingField = nil
        }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.l)
            $0.leading.equalToSuperview().inset(Spacing.l)
        }
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(Spacing.l)
            $0.width.height.equalTo(30)
        }
        typeSelector.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Spacing.l)
            $0.leading.trailing.equalToSuperview().inset(Spacing.l)
            $0.height.equalTo(44)
        }
        priceField.snp.makeConstraints {
            $0.top.equalTo(typeSelector.snp.bottom).offset(Spacing.m)
            $0.leading.trailing.equalToSuperview().inset(Spacing.l)
        }
        quantityField.snp.makeConstraints {
            $0.top.equalTo(priceField.snp.bottom).offset(Spacing.s)
            $0.leading.trailing.equalToSuperview().inset(Spacing.l)
        }
        percentRow.snp.makeConstraints {
            $0.top.equalTo(quantityField.snp.bottom).offset(Spacing.m)
            $0.leading.trailing.equalToSuperview().inset(Spacing.l)
            $0.height.equalTo(36)
        }
        availableLabel.snp.makeConstraints {
            $0.top.equalTo(percentRow.snp.bottom).offset(Spacing.m)
            $0.leading.equalToSuperview().inset(Spacing.l)
        }
        totalLabel.snp.makeConstraints {
            $0.top.equalTo(availableLabel.snp.bottom).offset(Spacing.xs)
            $0.leading.equalToSuperview().inset(Spacing.l)
        }
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(totalLabel.snp.bottom).offset(Spacing.s)
            $0.leading.trailing.equalToSuperview().inset(Spacing.l)
        }
        submitButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Spacing.l)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.m)
            $0.height.equalTo(52)
        }
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                break
            case .loaded(let snapshot):
                self.render(snapshot)
            case .error(let message):
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
            }
        }
    }

    private func render(_ snapshot: OrderEntryViewModel.Snapshot) {
        errorLabel.isHidden = true

        updateTypeSelection(snapshot.orderType)

        if editingField != .price {
            priceField.setValue(format(snapshot.price))
        }
        if editingField != .quantity {
            quantityField.setValue(format(snapshot.quantity))
        }

        availableLabel.text = "Available: \(format(snapshot.available)) \(snapshot.availableAsset)"
        totalLabel.text = "Total ≈ \(format(snapshot.total)) \(quote)"

        submitButton.isEnabled = snapshot.canSubmit
        submitButton.alpha = snapshot.canSubmit ? 1 : 0.4
    }

    private func updateTypeSelection(_ selected: OrderType) {
        for (type, button) in typeButtons {
            let isSelected = type == selected
            button.backgroundColor = isSelected ? .appBackground : .clear
            button.setTitleColor(isSelected ? .appTextPrimary : .appTextSecondary, for: .normal)
        }
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func typeTapped(_ sender: UIButton) {
        viewModel.selectType(typeButtons[sender.tag].type)
    }

    @objc private func percentTapped(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.selectPercent(percents[sender.tag])
    }

    @objc private func submitTapped() {
        view.endEditing(true)
        viewModel.submit()
    }

    // MARK: - Helpers

    private func format(_ value: Double) -> String {
        if value == 0 { return "0" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
