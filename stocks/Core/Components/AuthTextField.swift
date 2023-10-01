import UIKit
import SnapKit

// Reusable dark input field for auth screens — matches Figma Component 14/15
final class AuthTextField: UIView {

    let textField: UITextField = {
        let tf = UITextField()
        tf.font = AppFonts.regular(14)
        tf.textColor = .appTextPrimary
        tf.tintColor = .appAccent
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()

    private lazy var eyeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.tintColor = .appTextSecondary
        btn.addTarget(self, action: #selector(toggleVisibility), for: .touchUpInside)
        return btn
    }()

    private let isSecure: Bool
    private var isVisible = false
    private var isPhone = false

    init(placeholder: String, isSecure: Bool = false) {
        self.isSecure = isSecure
        super.init(frame: .zero)
        setup(placeholder: placeholder)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup(placeholder: String) {
        backgroundColor = .appSurface
        layer.cornerRadius = 12
        textField.delegate = self

        applyPlaceholder(placeholder)
        textField.isSecureTextEntry = isSecure
        addSubview(textField)

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(isSecure ? -52 : -20)
        }

        guard isSecure else { return }
        updateEyeIcon()
        addSubview(eyeButton)
        eyeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
    }

    // MARK: - Public

    func updatePlaceholder(_ text: String) {
        applyPlaceholder(text)
        textField.text = nil
    }

    // Enables/disables +7 (XXX) XXX-XX-XX masking for phone input
    func setPhoneMode(_ enabled: Bool) {
        isPhone = enabled
        if enabled {
            textField.text = nil
            textField.keyboardType = .phonePad
        }
    }

    // MARK: - Private

    private func applyPlaceholder(_ text: String) {
        textField.attributedPlaceholder = NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.appTextSecondary,
            .font: AppFonts.regular(14)
        ])
    }

    private func updateEyeIcon() {
        let name = isVisible ? "eye" : "eye.slash"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        eyeButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }

    @objc private func toggleVisibility() {
        isVisible.toggle()
        textField.isSecureTextEntry = !isVisible
        updateEyeIcon()
    }

    // MARK: - Phone formatting

    private func formatPhone(_ digits: String) -> String {
        let d = Array(digits.prefix(10))
        var result = "+7"
        guard !d.isEmpty else { return result }

        result += " (\(String(d[0..<min(3, d.count)]))"
        guard d.count >= 3 else { return result }

        result += ") \(String(d[3..<min(6, d.count)]))"
        guard d.count >= 6 else { return result }

        result += "-\(String(d[6..<min(8, d.count)]))"
        guard d.count >= 8 else { return result }

        result += "-\(String(d[8..<min(10, d.count)]))"
        return result
    }
}

// MARK: - UITextFieldDelegate

extension AuthTextField: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard isPhone else { return true }

        let current = textField.text ?? ""
        guard let swiftRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: swiftRange, with: string)

        // Strip everything except digits, then drop leading 7/8 (country code)
        var digits = updated.filter { $0.isNumber }
        if digits.hasPrefix("7") || digits.hasPrefix("8") {
            digits = String(digits.dropFirst())
        }

        textField.text = formatPhone(String(digits.prefix(10)))
        return false
    }
}
