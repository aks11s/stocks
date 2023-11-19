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
        l.text = "U"
        l.font = AppFonts.bold(32)
        l.textColor = .appAccent
        l.textAlignment = .center
        return l
    }()

    private lazy var usernameLabel: UILabel = {
        let l = UILabel()
        l.attributedText = NSAttributedString(string: "User1234", attributes: [
            .font: AppFonts.bold(18),
            .foregroundColor: UIColor.white,
            .kern: 18 * 0.0264,
        ])
        return l
    }()

    private lazy var usernameRow  = makeRow(label: "Username",      value: "Username1234")
    private lazy var emailRow     = makeRow(label: "Email",         value: "example@mail.com")
    private lazy var phoneRow     = makeRow(label: "Mobile Number", value: "+1 234 567 8900")
    private lazy var passwordRow  = makeRow(label: "Password",      value: "*********")

    // Closing separator at the bottom of the last row — matches Figma Vector 12 at content y=424
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Gradient covers exactly the top 175pt of the frame (Figma: Rectangle 49, h=175)
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
        // Header group: Figma absolute y=40. Status bar ≈ 44pt → safeArea.top + 0
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }

        // "Profile" title: Figma x=72 (24+48), vertically centered in back button
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(4)
            make.centerY.equalTo(backButton)
        }

        // Avatar: Figma content group y=111, absolute center x=207 (screen center).
        // From safeArea: 111 - 44 = 67pt
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(67)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // Username: Figma content y=124, avatar bottom+14pt (235-221=14)
        usernameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView.snp.bottom).offset(14)
        }

        // First separator (row top) at Figma content y=176 → username bottom+30pt (287-257=30)
        // Each row is 62pt tall (Figma: 238-176=62)
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

        // Closing separator: Figma Vector 12 at content y=424, i.e. right after last row
        bottomSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(passwordRow.snp.bottom)
            make.height.equalTo(0.5)
        }
    }

    // MARK: - Helpers

    private func makeRow(label: String, value: String) -> ProfileInfoRowView {
        let row = ProfileInfoRowView()
        row.configure(label: label, value: value)
        return row
    }

    // MARK: - Actions

    @objc private func backTapped() {
        dismiss(animated: true)
    }
}
