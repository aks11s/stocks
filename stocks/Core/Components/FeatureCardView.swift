import UIKit
import SnapKit

final class FeatureCardView: UIView {

    // MARK: - Subviews

    private lazy var iconBox: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor.appBackground.cgColor, UIColor.appAccent.cgColor]
        // 135° diagonal
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint   = CGPoint(x: 1, y: 1)
        return g
    }()

    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(16)
        l.textColor = .appBackground
        return l
    }()

    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appTextMuted
        return l
    }()

    private lazy var arrowView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_arrow_right"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = iconBox.bounds
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = UIColor(red: 227/255, green: 232/255, blue: 237/255, alpha: 0.5)
        layer.cornerRadius = 16

        iconBox.layer.addSublayer(gradientLayer)
        iconBox.addSubview(iconImageView)

        [iconBox, titleLabel, subtitleLabel, arrowView].forEach { addSubview($0) }
    }

    private func setupLayout() {
        // icon box — left side, vertically centered
        iconBox.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        // icon image inside box
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }

        // title at x=80 → 80pt from leading
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(80)
            make.top.equalToSuperview().inset(17)
            make.trailing.equalTo(arrowView.snp.leading).offset(-8)
        }

        // subtitle
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(80)
            make.top.equalToSuperview().offset(44)
            make.trailing.equalTo(arrowView.snp.leading).offset(-8)
        }

        // arrow — right side, x=308
        arrowView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview().offset(308)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - Configure

    func configure(title: String, subtitle: String, icon: UIImage?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = icon
    }
}
