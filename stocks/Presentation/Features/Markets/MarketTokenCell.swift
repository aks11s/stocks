import UIKit
import SnapKit

final class MarketTokenCell: UITableViewCell {

    static let reuseId = "MarketTokenCell"

    // MARK: - Subviews

    private lazy var logoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var nameLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(14)
        l.textColor = .appTextPrimary
        return l
    }()

    private lazy var pairLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(12)
        l.textColor = .appTextSecondary
        return l
    }()

    private lazy var priceLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(14)
        l.textColor = .appTextPrimary
        l.textAlignment = .right
        return l
    }()

    private lazy var changeLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textAlignment = .right
        return l
    }()

    private lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        return v
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupViews() {
        [logoView, nameLabel, pairLabel, priceLabel, changeLabel, separator].forEach {
            contentView.addSubview($0)
        }
    }

    private func setupLayout() {
        logoView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoView.snp.trailing).offset(13)
            make.top.equalTo(logoView.snp.top).offset(2)
        }

        pairLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(nameLabel)
            make.width.equalTo(100)
        }

        changeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.width.equalTo(100)
        }

        separator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    // MARK: - Configure

    func configure(with token: MarketToken) {
        logoView.image = UIImage(named: token.logoName)
        nameLabel.text = token.name
        pairLabel.text = token.pair
        priceLabel.text = token.price
        changeLabel.text = token.change
        changeLabel.textColor = token.isUptrend ? .appAccent : .appRed
    }
}
