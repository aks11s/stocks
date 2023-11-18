import UIKit
import SnapKit

final class HomeHeaderView: UIView {

    // MARK: - Subviews

    private lazy var avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appAccent.withAlphaComponent(0.3)
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private lazy var avatarLabel: UILabel = {
        let l = UILabel()
        l.text = "A"
        l.font = AppFonts.bold(14)
        l.textColor = .appAccent
        l.textAlignment = .center
        return l
    }()

    // Called when the user taps the avatar — owner handles navigation
    var onAvatarTap: (() -> Void)?

    // Icons from Figma: search(x=252), scan(x=304), notif(x=356)
    private lazy var searchButton = makeIconButton(named: "icon_search")
    private lazy var scanButton   = makeIconButton(named: "icon_scan")
    private lazy var notifButton  = makeIconButton(named: "icon_notif")

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
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
    }

    private func setupLayout() {
        // Icons are at y=37 from the top of screen in Figma (on iPhone 11 with 44pt status bar).
        // We pin relative to safeAreaLayoutGuide so they sit correctly on any device.
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        searchButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().offset(252)
            make.top.equalTo(safeAreaLayoutGuide)
        }

        scanButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().offset(304)
            make.top.equalTo(safeAreaLayoutGuide)
        }

        notifButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().offset(356)
            make.top.equalTo(safeAreaLayoutGuide)
        }
    }

    // MARK: - Actions

    @objc private func avatarTapped() {
        onAvatarTap?()
    }

    private func makeIconButton(named name: String) -> UIView {
        let v = UIView()

        let iv = UIImageView(image: UIImage(named: name))
        iv.contentMode = .scaleAspectFit
        v.addSubview(iv)

        // Icons are 22×22 clean SVGs — render at native size inside 44×44 tap area
        iv.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.center.equalToSuperview()
        }
        return v
    }
}
