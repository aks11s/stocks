import UIKit

final class OrderCell: UITableViewCell {

    static let reuseID = "OrderCell"

    // MARK: - Views

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.medium(16)
        label.textColor = .appTextPrimary
        return label
    }()

    private let sideLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regular(13)
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.medium(16)
        label.textColor = .appTextPrimary
        label.textAlignment = .right
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regular(13)
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
        let leftStack = UIStackView(arrangedSubviews: [symbolLabel, sideLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let rightStack = UIStackView(arrangedSubviews: [amountLabel, statusLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 4

        [leftStack, rightStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.l),
            leftStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            rightStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.l),
            rightStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
    }

    // MARK: - Configure

    func configure(with order: Order) {
        symbolLabel.text = order.symbol

        let sideText = order.side == .buy ? "Buy" : "Sell"
        sideLabel.text = "\(sideText) · \(typeText(order.type))"
        sideLabel.textColor = order.side == .buy ? .appAccent : .appRed

        amountLabel.text = "\(trim(order.quantity)) @ \(String(format: "%.2f", order.price))"

        statusLabel.text = order.status.rawValue.capitalized
        statusLabel.textColor = statusColor(order.status)
    }

    // MARK: - Helpers

    private func typeText(_ type: OrderType) -> String {
        switch type {
        case .market:    return "Market"
        case .limit:     return "Limit"
        case .stopLimit: return "Stop-Limit"
        }
    }

    private func statusColor(_ status: OrderStatus) -> UIColor {
        switch status {
        case .pending:   return .appGold
        case .filled:    return .appAccent
        case .cancelled: return .appTextSecondary
        }
    }

    private func trim(_ value: Double) -> String {
        String(format: "%.4f", value)
    }
}
