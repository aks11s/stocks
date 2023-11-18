import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    // MARK: - Subviews

    // Gradient fades from transparent at top to accent at bottom — matches Figma overlay
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
        let img = UIImage(named: "icon_arrow_right")?.withRenderingMode(.alwaysTemplate)
        b.setImage(img, for: .normal)
        b.tintColor = .white
        b.transform = CGAffineTransform(scaleX: -1, y: 1)
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

    private lazy var usernameRow   = makeRow(label: "Username",      value: "Username1234")
    private lazy var emailRow      = makeRow(label: "Email",         value: "example@mail.com")
    private lazy var phoneRow      = makeRow(label: "Mobile Number", value: "+1 234 567 8900")
    private lazy var passwordRow   = makeRow(label: "Password",      value: "*********")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
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
         usernameRow, emailRow, phoneRow, passwordRow].forEach { view.addSubview($0) }
        avatarView.addSubview(avatarLabel)
    }

    private func setupLayout() {
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(4)
            make.centerY.equalTo(backButton)
        }

        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(111)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        usernameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView.snp.bottom).offset(14)
        }

        // Rows start 62pt below username (mirrors Figma content y=201 after avatar+name block)
        usernameRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(usernameLabel.snp.bottom).offset(62)
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
