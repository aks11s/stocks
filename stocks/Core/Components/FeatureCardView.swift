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
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint   = CGPoint(x: 1, y: 1)
        g.locations  = [0.29, 1.0]
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

    private static let titleKern: CGFloat = 16 * 0.0264
    private static let subtitleKern: CGFloat = 14 * 0.0264

    private lazy var arrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_arrow_right"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    var onTap: (() -> Void)?

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

        [iconBox, titleLabel, subtitleLabel, arrowImageView].forEach { addSubview($0) }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    private func setupLayout() {
        iconBox.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        arrowImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.trailing.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(80)
            make.top.equalToSuperview().inset(17)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(80)
            make.top.equalToSuperview().offset(44)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
        }
    }

    // MARK: - Configure

    @objc private func handleTap() {
        onTap?()
    }

    func configure(title: String, subtitle: String, icon: UIImage?) {
        titleLabel.attributedText = NSAttributedString(string: title, attributes: [
            .font: AppFonts.regular(16),
            .foregroundColor: UIColor.appBackground,
            .kern: FeatureCardView.titleKern,
        ])
        subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: [
            .font: AppFonts.regular(14),
            .foregroundColor: UIColor.appTextMuted,
            .kern: FeatureCardView.subtitleKern,
        ])
        iconImageView.image = icon
    }
}
