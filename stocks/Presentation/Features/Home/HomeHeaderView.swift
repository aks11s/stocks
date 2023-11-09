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
        addSubview(avatarView)
    }

    private func setupLayout() {
        avatarView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
        }

        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
