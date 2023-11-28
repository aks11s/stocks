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
        let img = UIImage(named: "icon_arrow_left")?.withRenderingMode(.alwaysTemplate)
        b.setImage(img, for: .normal)
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
        v.backgroundColor = UIColor.appAccent.withAlphaComponent(0.3)
        v.layer.cornerRadius = 55
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 1
        v.clipsToBounds = true
        return v
    }()

    private lazy var avatarLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(32)
        l.textColor = .appAccent
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

    private func loadProfile() {
        let storage = ProfileStorage.shared

        // Show first letter of username as avatar, fall back to "U"
        let initial = storage.username?.first.map { String($0).uppercased() } ?? "U"
        avatarLabel.text = initial
        usernameLabel.text = storage.username ?? "User"

        usernameRow.configure(label: "Username",      value: storage.username)
        emailRow.configure(label: "Email",            value: storage.email)
        phoneRow.configure(label: "Mobile Number",    value: storage.phone)

        // Show masked dots if password is saved, nil otherwise
        let maskedPassword = storage.passwordHash != nil ? "••••••••" : nil
        passwordRow.configure(label: "Password", value: maskedPassword)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        dismiss(animated: true)
    }
}
