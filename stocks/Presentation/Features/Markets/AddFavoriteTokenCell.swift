import UIKit
import SnapKit

final class AddFavoriteTokenCell: UITableViewCell {

    static let reuseId = "AddFavoriteTokenCell"

    var onAdd: (() -> Void)?

    // MARK: - Subviews

    private lazy var logoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var pairLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(14)
        l.textColor = .appTextPrimary
        return l
    }()

    private lazy var priceLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(12)
        l.textColor = .appTextSecondary
        return l
    }()

    private lazy var addButton: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 14
        b.clipsToBounds = true
        b.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return b
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
        [logoView, pairLabel, priceLabel, addButton, separator].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        logoView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        pairLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoView.snp.trailing).offset(13)
            make.top.equalTo(logoView).offset(4)
            make.trailing.lessThanOrEqualTo(addButton.snp.leading).offset(-12)
        }

        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(pairLabel)
            make.top.equalTo(pairLabel.snp.bottom).offset(4)
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    // MARK: - Configure

    func configure(with token: SearchToken) {
        logoView.image = UIImage(named: token.logoName)
        pairLabel.text = token.pair
        priceLabel.text = token.price
        setAdded(token.isAdded)
    }

    private func setAdded(_ added: Bool) {
        if added {
            let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            let icon = UIImage(systemName: "checkmark", withConfiguration: config)?
                .withTintColor(.appBackground, renderingMode: .alwaysOriginal)
            addButton.setImage(icon, for: .normal)
            addButton.backgroundColor = .appAccent
            addButton.isUserInteractionEnabled = false
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            let icon = UIImage(systemName: "plus", withConfiguration: config)?
                .withTintColor(.appTextPrimary, renderingMode: .alwaysOriginal)
            addButton.setImage(icon, for: .normal)
            addButton.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            addButton.isUserInteractionEnabled = true
        }
    }

    // MARK: - Actions

    @objc private func addTapped() {
        onAdd?()
    }
}
