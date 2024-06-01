import UIKit
import SnapKit

final class OrderStepperFieldView: UIView {

    // true = +, false = −
    var onStep: ((Bool) -> Void)?
    var onValueEdited: ((Double) -> Void)?

    private let titleLabel = UILabel()
    private let valueField = UITextField()
    private lazy var plusButton  = makeStepButton(symbol: "plus")
    private lazy var minusButton = makeStepButton(symbol: "minus")

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    func setValue(_ text: String) {
        valueField.text = text
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .appSurfaceCard
        layer.cornerRadius = 12

        titleLabel.font = AppFonts.regular(14)
        titleLabel.textColor = .appTextSecondary

        valueField.font = AppFonts.medium(18)
        valueField.textColor = .appTextPrimary
        valueField.keyboardType = .decimalPad
        valueField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)

        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)

        [titleLabel, valueField, plusButton, minusButton].forEach { addSubview($0) }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Spacing.s + 2)
            $0.leading.equalToSuperview().inset(Spacing.m)
        }

        valueField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Spacing.m)
            $0.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            $0.bottom.equalToSuperview().inset(Spacing.s + 2)
            $0.trailing.lessThanOrEqualTo(plusButton.snp.leading).offset(-Spacing.s)
        }

        minusButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Spacing.s)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }

        plusButton.snp.makeConstraints {
            $0.trailing.equalTo(minusButton.snp.leading).offset(-Spacing.s)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
    }

    // MARK: - Actions

    @objc private func plusTapped()  { onStep?(true) }
    @objc private func minusTapped() { onStep?(false) }

    @objc private func valueChanged() {
        let text = (valueField.text ?? "").replacingOccurrences(of: ",", with: ".")
        onValueEdited?(Double(text) ?? 0)
    }

    // MARK: - Helpers

    private func makeStepButton(symbol: String) -> UIButton {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        b.setImage(UIImage(systemName: symbol, withConfiguration: config), for: .normal)
        b.tintColor = .appTextPrimary
        b.backgroundColor = .appBackground
        b.layer.cornerRadius = 8
        return b
    }
}
