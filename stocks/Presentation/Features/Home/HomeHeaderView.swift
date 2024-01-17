import UIKit
import SnapKit

final class HomeHeaderView: UIView {

    // MARK: - Subviews

    private lazy var avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = .appAccent
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private lazy var avatarLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(14)
        l.textColor = .appBackground
        l.textAlignment = .center
        l.text = ProfileStorage.shared.username?.first.map { String($0).uppercased() } ?? "U"
        return l
    }()

    var onAvatarTap: (() -> Void)?
    var onScanTap: (() -> Void)?
    var onNotifTap: (() -> Void)?

    private lazy var searchButton = makeIconButton(named: "icon_search")
    private lazy var scanButton   = makeIconButton(named: "icon_scan")
    private lazy var notifButton  = makeIconButton(named: "icon_notif")

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        setupShadow()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .appBackground
        avatarView.addSubview(avatarLabel)
        [avatarView, searchButton, scanButton, notifButton].forEach { addSubview($0) }

        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarView.addGestureRecognizer(tap)
        avatarView.isUserInteractionEnabled = true

        scanButton.addTarget(self, action: #selector(scanTapped), for: .touchUpInside)
        notifButton.addTarget(self, action: #selector(notifTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
            make.width.height.equalTo(36)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // Figma: notif trailing=14pt, icons 44×44, 8pt gap between each
        notifButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalTo(avatarView)
            make.width.height.equalTo(44)
        }

        scanButton.snp.makeConstraints { make in
            make.trailing.equalTo(notifButton.snp.leading).offset(-8)
            make.centerY.equalTo(avatarView)
            make.width.height.equalTo(44)
        }

        searchButton.snp.makeConstraints { make in
            make.trailing.equalTo(scanButton.snp.leading).offset(-8)
            make.centerY.equalTo(avatarView)
            make.width.height.equalTo(44)
        }
    }

    private func setupShadow() {
        // Figma: 0px 12px 16px rgba(22, 28, 34, 0.5)
        layer.shadowColor = UIColor(red: 22/255, green: 28/255, blue: 34/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 16
        layer.shadowOpacity = 0.5
    }

    // MARK: - Actions

    @objc private func avatarTapped() { onAvatarTap?() }
    @objc private func scanTapped()   { onScanTap?() }
    @objc private func notifTapped()  { onNotifTap?() }

    private func makeIconButton(named name: String) -> UIButton {
        let b = UIButton(type: .system)
        let img = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
        b.setImage(img, for: .normal)
        b.tintColor = .appAccent
        return b
    }
}
