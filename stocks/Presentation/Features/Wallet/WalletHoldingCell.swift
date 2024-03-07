import UIKit

final class WalletHoldingCell: UITableViewCell {

    static let reuseID = "WalletHoldingCell"

    // MARK: - Views

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.medium(16)
        label.textColor = .appTextPrimary
        return label
    }()

    private let tickerLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regular(13)
        label.textColor = .appTextSecondary
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.medium(16)
        label.textColor = .appTextPrimary
        label.textAlignment = .right
        return label
    }()

    private let fiatLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regular(13)
        label.textColor = .appTextSecondary
        label.textAlignment = .right
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    private func setupLayout() {
        let leftStack = UIStackView(arrangedSubviews: [nameLabel, tickerLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let rightStack = UIStackView(arrangedSubviews: [amountLabel, fiatLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 4

        [iconImageView, leftStack, rightStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.l),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            leftStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Spacing.m),
            leftStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            rightStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.l),
            rightStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
    }

    // MARK: - Configure

    func configure(with entry: HoldingEntry) {
        nameLabel.text = entry.name
        tickerLabel.text = entry.symbol
        amountLabel.text = String(format: "%.2f", entry.amount)
        fiatLabel.text = String(format: "$%.2f", entry.fiatValue)
        iconImageView.image = UIImage(named: entry.symbol.lowercased())
    }
}
