import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    // MARK: - Subviews

    // Gradient fades from transparent (top) to accent (bottom) — Figma: 180deg, y=0..175
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
        b.setImage(UIImage(named: "icon_chevron_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.attributedText = NSAttributedString(string: "Profile", attributes: [
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

    private lazy var avatarLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(32)
        l.textColor = .appBackground
        l.textAlignment = .center
        return l
    }()

    private lazy var usernameLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(18)
        l.textColor = .white
        return l
    }()

    private lazy var usernameRow  = ProfileInfoRowView()
    private lazy var emailRow     = ProfileInfoRowView()
    private lazy var phoneRow     = ProfileInfoRowView()
    private lazy var passwordRow  = ProfileInfoRowView()

    private lazy var bottomSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload every time we come back from edit screen
        loadProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 175)
    }

    // MARK: - Setup

    private func setupViews() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        [backButton, titleLabel,
         avatarView, usernameLabel,
         usernameRow, emailRow, phoneRow, passwordRow,
         bottomSeparator].forEach { view.addSubview($0) }
        avatarView.addSubview(avatarLabel)
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

        // Avatar: Figma content group y=111, from safeArea: 111-44=67pt
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(67)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // Username: Figma avatar bottom + 14pt gap
        usernameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView.snp.bottom).offset(14)
        }

        // First separator at Figma content y=176 → username bottom + 30pt
        // Each row is 62pt tall
        usernameRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(usernameLabel.snp.bottom).offset(30)
            make.height.equalTo(62)
        }

        emailRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(usernameRow.snp.bottom)
            make.height.equalTo(62)
        }

        phoneRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(emailRow.snp.bottom)
            make.height.equalTo(62)
        }

        passwordRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(phoneRow.snp.bottom)
            make.height.equalTo(62)
        }

        bottomSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(passwordRow.snp.bottom)
            make.height.equalTo(0.5)
        }
    }

    // MARK: - Data

    private func openEdit() {
        let vc = EditProfileViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func loadProfile() {
        let storage = ProfileStorage.shared

        avatarLabel.text = storage.username?.first.map { String($0).uppercased() } ?? "U"
        usernameLabel.text = storage.username ?? "User"

        usernameRow.configure(label: "Username",      value: storage.username)
        emailRow.configure(label: "Email",            value: storage.email)
        phoneRow.configure(label: "Mobile Number",    value: storage.phone.map { formatPhone($0) })

        // Show masked dots if password is saved, nil otherwise
        let maskedPassword = storage.passwordHash != nil ? "••••••••" : nil
        passwordRow.configure(label: "Password", value: maskedPassword)

        // Any row tap or "Add" button opens the edit screen
        [usernameRow, emailRow, phoneRow, passwordRow].forEach { row in
            row.onAddTap = { [weak self] in self?.openEdit() }
            row.onRowTap = { [weak self] in self?.openEdit() }
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    // MARK: - Helpers

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
