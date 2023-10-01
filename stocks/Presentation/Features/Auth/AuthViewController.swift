import UIKit
import SnapKit

final class AuthViewController: UIViewController {

    private let viewModel: AuthViewModel
    var onFinish: (() -> Void)?

    // MARK: - Views

    private lazy var titleLabel = makeAuthLabel("Sign in", font: AppFonts.bold(32), color: .appTextPrimary)
    private lazy var fieldLabel = makeAuthLabel(viewModel.fieldLabel, font: AppFonts.regular(14), color: .appTextMuted)

    private lazy var toggleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(viewModel.toggleTitle, for: .normal)
        btn.setTitleColor(.appAccent, for: .normal)
        btn.titleLabel?.font = AppFonts.regular(14)
        btn.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var inputField = AuthTextField(placeholder: viewModel.fieldPlaceholder)
    private lazy var passwordLabel = makeAuthLabel("Password", font: AppFonts.regular(14), color: .appTextMuted)
    private lazy var passwordField = AuthTextField(placeholder: "Enter your password", isSecure: true)

    private lazy var forgotButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot password?", for: .normal)
        btn.setTitleColor(.appAccent, for: .normal)
        btn.titleLabel?.font = AppFonts.regular(14)
        return btn
    }()

    private lazy var signInButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .appAccent
        btn.layer.cornerRadius = 16
        btn.setTitle("Sign in", for: .normal)
        btn.setTitleColor(.appButtonLabel, for: .normal)
        btn.titleLabel?.font = AppFonts.regular(18)
        btn.layer.shadowColor = UIColor.appAccent.withAlphaComponent(0.16).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 20)
        btn.layer.shadowRadius = 30
        btn.layer.shadowOpacity = 1
        btn.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var orLabel = makeAuthLabel("Or login with", font: AppFonts.regular(14), color: .appTextSecondary)
    private lazy var facebookButton = makeSocialButton(title: "Facebook")
    private lazy var googleButton   = makeSocialButton(title: "Google")

    private lazy var fingerprintLabel = makeAuthLabel("Use fingerprint instead?",
                                                      font: AppFonts.regular(14),
                                                      color: .appTextMuted)

    // MARK: - Init

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupBindings()
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = .appBackground
        orLabel.textAlignment = .center
        fingerprintLabel.textAlignment = .center
        [titleLabel, fieldLabel, toggleButton, inputField,
         passwordLabel, passwordField, forgotButton, signInButton,
         orLabel, facebookButton, googleButton, fingerprintLabel].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
        }

        fieldLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.top.equalTo(titleLabel.snp.bottom).offset(44)
        }

        toggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Spacing.l)
            $0.centerY.equalTo(fieldLabel)
        }

        inputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.trailing.equalToSuperview().offset(-Spacing.l)
            $0.top.equalTo(fieldLabel.snp.bottom).offset(12)
            $0.height.equalTo(54)
        }

        passwordLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.top.equalTo(inputField.snp.bottom).offset(30)
        }

        passwordField.snp.makeConstraints {
            $0.leading.trailing.equalTo(inputField)
            $0.top.equalTo(passwordLabel.snp.bottom).offset(12)
            $0.height.equalTo(54)
        }

        forgotButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.top.equalTo(passwordField.snp.bottom).offset(8)
        }

        signInButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(inputField)
            $0.top.equalTo(forgotButton.snp.bottom).offset(40)
            $0.height.equalTo(54)
        }

        orLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(signInButton.snp.bottom).offset(20)
        }

        facebookButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.top.equalTo(orLabel.snp.bottom).offset(20)
            $0.height.equalTo(54)
        }

        googleButton.snp.makeConstraints {
            $0.leading.equalTo(facebookButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-Spacing.l)
            $0.top.height.equalTo(facebookButton)
            $0.width.equalTo(facebookButton)
        }

        fingerprintLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(facebookButton.snp.bottom).offset(55)
        }
    }

    private func setupBindings() {
        viewModel.onInputModeChanged = { [weak self] mode in
            guard let self else { return }
            self.fieldLabel.text = self.viewModel.fieldLabel
            self.toggleButton.setTitle(self.viewModel.toggleTitle, for: .normal)
            self.inputField.updatePlaceholder(self.viewModel.fieldPlaceholder)
            self.inputField.textField.keyboardType = mode == .phone ? .phonePad : .emailAddress
        }

        viewModel.onSuccess = { [weak self] in
            self?.onFinish?()
        }

        viewModel.onValidationError = { [weak self] message in
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func toggleTapped() {
        viewModel.toggleInputMode()
    }

    @objc private func signInTapped() {
        view.endEditing(true)
        viewModel.signIn(
            input: inputField.textField.text ?? "",
            password: passwordField.textField.text ?? ""
        )
    }
}

// MARK: - Helpers

private func makeAuthLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
    let lbl = UILabel()
    lbl.text = text
    lbl.font = font
    lbl.textColor = color
    return lbl
}

private func makeSocialButton(title: String) -> UIButton {
    let btn = UIButton(type: .custom)
    btn.backgroundColor = .appSurface
    btn.layer.cornerRadius = 16
    btn.setTitle(title, for: .normal)
    btn.setTitleColor(.appTextPrimary, for: .normal)
    btn.titleLabel?.font = AppFonts.regular(18)
    return btn
}
