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
}
