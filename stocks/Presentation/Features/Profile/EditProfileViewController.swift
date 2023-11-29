import UIKit
import SnapKit
import PhotosUI

final class EditProfileViewController: UIViewController {

    // MARK: - Subviews

    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor.appBackground.withAlphaComponent(0).cgColor,
                    UIColor.appAccent.cgColor]
        g.startPoint = CGPoint(x: 0.5, y: 0)
        g.endPoint   = CGPoint(x: 0.5, y: 1)
        return g
    }()

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        let img = UIImage(named: "icon_arrow_left")?.withRenderingMode(.alwaysTemplate)
        b.setImage(img, for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.attributedText = NSAttributedString(string: "Edit Profile", attributes: [
            .font: AppFonts.bold(18),
            .foregroundColor: UIColor.white,
            .kern: 18 * 0.0264,
        ])
        return l
    }()

    private lazy var avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = .appAccent
        v.layer.cornerRadius = 55
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 1
        v.clipsToBounds = true
        return v
    }()

    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.isHidden = true
        return iv
    }()

    private lazy var avatarLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(32)
        l.textColor = .appBackground
        l.textAlignment = .center
        return l
    }()

    // Camera overlay on the avatar — tapping opens the photo library (Figma: camera-plus-outline, 36×36)
    private lazy var cameraButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "icon_camera_gallery"), for: .normal)
        b.tintColor = .clear  // icon has its own colors baked in
        b.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        return b
    }()

    private lazy var usernameField  = makeField(placeholder: "Username")
    private lazy var emailField     = makeField(placeholder: "Email", keyboardType: .emailAddress)
    private lazy var passwordField  = makeField(placeholder: "Password", isSecure: true)
    private lazy var phoneField     = makeField(placeholder: "Mobile Number", keyboardType: .phonePad)

    // Save Changes: accent bg, dark text — Figma: 179×54, cornerRadius 16, bg #5ED5A8
    private lazy var saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save Changes", for: .normal)
        b.setTitleColor(.appButtonLabel, for: .normal)
        b.titleLabel?.font = AppFonts.regular(18)
        b.backgroundColor = .appAccent
        b.layer.cornerRadius = 16
        b.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return b
    }()

    // Cancel: transparent bg, white text — Figma: 179×54, cornerRadius 16
    private lazy var cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = AppFonts.regular(18)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        b.layer.cornerRadius = 16
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    // Eye button toggles password visibility — Figma: Bulk Icons=Show, 44×44
    private lazy var eyeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "icon_eye"), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        return b
    }()

    private lazy var usernameLabel  = makeFieldLabel("Username")
    private lazy var emailLabel     = makeFieldLabel("Email")
    private lazy var passwordLabel  = makeFieldLabel("Password")
    private lazy var phoneLabel     = makeFieldLabel("Mobile Number")

    // Tracks whether the password field still shows the "already set" placeholder
    // — if the user never touched it, we skip updating the hash on save
    private var passwordIsUnchanged = false

    // Separators between field groups
    private lazy var separators: [UIView] = (0..<5).map { _ in
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
        loadCurrentValues()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 175)
    }

    // MARK: - Setup

    private func setupViews() {
        view.layer.insertSublayer(gradientLayer, at: 0)

        avatarView.addSubview(avatarLabel)
        avatarView.addSubview(avatarImageView)
        view.addSubview(avatarView)
        view.addSubview(cameraButton)
        view.addSubview(backButton)
        view.addSubview(titleLabel)

        separators.forEach { view.addSubview($0) }

        view.addSubview(saveButton)
        view.addSubview(cancelButton)

        phoneField.delegate = self
        passwordField.delegate = self

        [(usernameLabel, usernameField, nil),
         (emailLabel,    emailField,    nil),
         (passwordLabel, passwordField, eyeButton as UIView?),
         (phoneLabel,    phoneField,    nil)].forEach { label, field, extra in
            view.addSubview(label)
            view.addSubview(field)
            if let extra { view.addSubview(extra) }
        }
    }

    private func setupLayout() {
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(4)
            make.centerY.equalTo(backButton)
        }

        // Avatar: same position as Profile screen
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(67)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Camera icon: Figma x=209 rel content (content x=24), avatar right-bottom corner
        // Avatar trailing = screen center + 55 = 207+55=262, camera at 24+209=233 → trailing of avatar - 29pt
        cameraButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.trailing.equalTo(avatarView.snp.trailing)
            make.bottom.equalTo(avatarView.snp.bottom)
        }

        // Field rows: Figma content y starts at 111, first separator at content y=176
        // From safeArea: 111+176-44 = 243pt → from avatar bottom (safeArea+177): 243-177=66pt
        layoutFieldRow(
            separator: separators[0],
            label: usernameLabel,
            field: usernameField,
            eye: nil,
            topAnchor: avatarView.snp.bottom,
            topOffset: 66
        )
        layoutFieldRow(
            separator: separators[1],
            label: emailLabel,
            field: emailField,
            eye: nil,
            topAnchor: separators[0].snp.bottom,
            topOffset: 82   // row height = 82pt (Figma: 258-176=82)
        )
        layoutFieldRow(
            separator: separators[2],
            label: passwordLabel,
            field: passwordField,
            eye: eyeButton,
            topAnchor: separators[1].snp.bottom,
            topOffset: 77   // Figma: 335-258=77
        )
        layoutFieldRow(
            separator: separators[3],
            label: phoneLabel,
            field: phoneField,
            eye: nil,
            topAnchor: separators[2].snp.bottom,
            topOffset: 77   // Figma: 412-335=77
        )

        // Closing separator after last row
        separators[4].snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(separators[3].snp.bottom).offset(77)
            make.height.equalTo(0.5)
        }

        // Buttons: Figma content y=549, each 179×54 with 8pt gap between them
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(separators[4].snp.bottom).offset(60)
            make.height.equalTo(54)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.equalTo(cancelButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(24)
            make.width.equalTo(cancelButton)
            make.top.equalTo(cancelButton)
            make.height.equalTo(54)
        }
    }

    private func layoutFieldRow(
        separator: UIView,
        label: UILabel,
        field: UITextField,
        eye: UIButton?,
        topAnchor: ConstraintRelatableTarget,
        topOffset: CGFloat
    ) {
        separator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(topAnchor).offset(topOffset)
            make.height.equalTo(0.5)
        }

        // Label: 12px, ~20pt below separator (Figma: label y offset within row ≈ 20-25pt)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(separator.snp.bottom).offset(20)
        }

        // Input field: ~32pt below separator (label bottom ~34pt + small gap)
        field.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(28)  // 4pt indent from edge (Figma x=4 within content)
            make.top.equalTo(separator.snp.bottom).offset(35)
            if let eye {
                make.trailing.equalTo(eye.snp.leading).offset(-8)
            } else {
                make.trailing.equalToSuperview().inset(24)
            }
        }

        eye?.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(field)
        }
    }

    // MARK: - Helpers

    private func makeField(placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.font = AppFonts.regular(14)
        tf.textColor = .white
        tf.keyboardType = keyboardType
        tf.isSecureTextEntry = isSecure
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.appTextSecondary]
        )
        return tf
    }

    private func makeFieldLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = AppFonts.regular(12)
        l.textColor = .appTextSecondary
        return l
    }

    // MARK: - Data

    private func loadCurrentValues() {
        let s = ProfileStorage.shared
        usernameField.text = s.username
        emailField.text    = s.email
        phoneField.text    = s.phone.map { formatPhone($0) }

        // Show placeholder dots if a password is already saved —
        // user must retype to change it, otherwise we keep the existing hash
        if s.passwordHash != nil {
            passwordField.text = "••••••••"
            passwordIsUnchanged = true
        }

        if let data = s.avatarImageData, let image = UIImage(data: data) {
            avatarImageView.image = image
            avatarImageView.isHidden = false
            avatarLabel.isHidden = true
        } else {
            avatarLabel.text = s.username?.first.map { String($0).uppercased() } ?? "U"
        }
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        ProfileStorage.shared.save(
            username: usernameField.text,
            email:    emailField.text,
            phone:    phoneField.text,
            password: passwordIsUnchanged ? nil : passwordField.text
        )
        dismiss(animated: true)
    }

    @objc private func cameraTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func togglePassword() {
        passwordField.isSecureTextEntry.toggle()
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear the placeholder dots so the user starts fresh when changing password
        if textField == passwordField && passwordIsUnchanged {
            passwordField.text = ""
            passwordIsUnchanged = false
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == phoneField else { return true }

        let current = textField.text ?? ""
        guard let swiftRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: swiftRange, with: string)

        var digits = updated.filter { $0.isNumber }
        if digits.hasPrefix("7") || digits.hasPrefix("8") {
            digits = String(digits.dropFirst())
        }
        textField.text = formatPhone(String(digits.prefix(10)))
        return false
    }

    // Formats raw digits (or already-masked string) into +7 (XXX) XXX-XX-XX
    private func formatPhone(_ input: String) -> String {
        var digits = input.filter { $0.isNumber }
        if digits.hasPrefix("7") || digits.hasPrefix("8") {
            digits = String(digits.dropFirst())
        }
        let d = Array(digits.prefix(10))
        guard !d.isEmpty else { return input }

        var result = "+7"
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

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            let data = image.jpegData(compressionQuality: 0.85)
            DispatchQueue.main.async {
                ProfileStorage.shared.avatarImageData = data
                self.avatarImageView.image = image
                self.avatarImageView.isHidden = false
                self.avatarLabel.isHidden = true
            }
        }
    }
}
