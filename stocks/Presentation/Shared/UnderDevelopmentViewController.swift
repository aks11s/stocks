import UIKit
import SnapKit

final class UnderDevelopmentViewController: UIViewController {

    // MARK: - Subviews

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        let img = UIImage(named: "icon_arrow_left")?.withRenderingMode(.alwaysTemplate)
        b.setImage(img, for: .normal)
        b.tintColor = .appAccent
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "screen_dev")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Screen Under Development"
        l.font = AppFonts.bold(18)
        l.textColor = .appTextPrimary
        l.textAlignment = .center
        return l
    }()

    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "We're working on something great.\nCheck back soon."
        l.font = AppFonts.regular(14)
        l.textColor = .appTextSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupViews()
        setupLayout()
    }

    // MARK: - Setup

    private func setupViews() {
        [backButton, imageView, titleLabel, subtitleLabel].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().inset(14)
            make.width.height.equalTo(44)
        }

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(180)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
