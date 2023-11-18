import UIKit
import SnapKit

final class ProfileInfoRowView: UIView {

    // MARK: - Subviews

    private lazy var labelText: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appLabelMuted
        return l
    }()

    private lazy var valueText: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appTextSecondary
        return l
    }()

    private lazy var arrowView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_arrow_right")?.withRenderingMode(.alwaysTemplate))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var separator: UIView = {
        let v = UIView()
        // Very subtle divider — matches Figma opacity ~0.02, bumped slightly for visibility
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
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
        [separator, labelText, valueText, arrowView].forEach { addSubview($0) }
    }

    private func setupLayout() {
        separator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        labelText.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        arrowView.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        valueText.snp.makeConstraints { make in
            make.trailing.equalTo(arrowView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - Configure

    func configure(label: String, value: String) {
        labelText.text = label
        valueText.text = value
    }
}
