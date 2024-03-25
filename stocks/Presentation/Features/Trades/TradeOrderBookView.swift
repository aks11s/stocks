import UIKit
import SnapKit

final class TradeOrderBookView: UIView {

    private static let visibleRows = 8

    // MARK: - Bid column

    private let bidHeader  = makeHeader("Bid")
    private let bidStack   = makeColumnStack()

    // MARK: - Ask column

    private let askHeader  = makeHeader("Ask")
    private let askStack   = makeColumnStack()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func configure(orderBook: OrderBook) {
        let bids = Array(orderBook.bids.prefix(Self.visibleRows))
        let asks = Array(orderBook.asks.prefix(Self.visibleRows))
        populate(stack: bidStack, entries: bids)
        populate(stack: askStack, entries: asks)
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .white

        let bidColumn = makeColumn(header: bidHeader, stack: bidStack)
        let askColumn = makeColumn(header: askHeader, stack: askStack)

        let separator = UIView()
        separator.backgroundColor = UIColor.appTextMuted.withAlphaComponent(0.2)

        addSubview(bidColumn)
        addSubview(separator)
        addSubview(askColumn)

        bidColumn.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(snp.centerX).offset(-1)
        }
        separator.snp.makeConstraints {
            $0.centerX.top.bottom.equalToSuperview()
            $0.width.equalTo(1)
        }
        askColumn.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.leading.equalTo(snp.centerX).offset(1)
        }

        prefillRows()
    }

    private func prefillRows() {
        for _ in 0..<Self.visibleRows {
            bidStack.addArrangedSubview(makeRow(price: "—", amount: "—"))
            askStack.addArrangedSubview(makeRow(price: "—", amount: "—"))
        }
    }

    // MARK: - Population

    private func populate(stack: UIStackView, entries: [OrderBookEntry]) {
        for (index, view) in stack.arrangedSubviews.enumerated() {
            guard let row = view as? UIStackView else { continue }
            let priceLabel  = row.arrangedSubviews[0] as? UILabel
            let amountLabel = row.arrangedSubviews[1] as? UILabel

            if index < entries.count {
                priceLabel?.text  = formatPrice(entries[index].price)
                amountLabel?.text = formatAmount(entries[index].amount)
            } else {
                priceLabel?.text  = "—"
                amountLabel?.text = "—"
            }
        }
    }

    // MARK: - Formatting

    private func formatPrice(_ value: Double) -> String {
        let formatted = String(format: "%.2f", value)
        return addThousandsSeparator(formatted)
    }

    private func formatAmount(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private func addThousandsSeparator(_ string: String) -> String {
        guard let dotRange = string.range(of: ".") else { return string }
        let intPart = String(string[string.startIndex..<dotRange.lowerBound])
        let decPart = String(string[dotRange.lowerBound...])
        let reversed = String(intPart.reversed())
        var result = ""
        for (i, ch) in reversed.enumerated() {
            if i > 0, i % 3 == 0 { result += "," }
            result.append(ch)
        }
        return String(result.reversed()) + decPart
    }
}

// MARK: - Factory helpers

private func makeHeader(_ title: String) -> UILabel {
    let l = UILabel()
    l.text = title
    l.font = AppFonts.regular(12)
    l.textColor = .appTextMuted
    return l
}

private func makeColumnStack() -> UIStackView {
    let s = UIStackView()
    s.axis = .vertical
    s.spacing = 4
    return s
}

private func makeColumn(header: UILabel, stack: UIStackView) -> UIView {
    let v = UIView()
    v.addSubview(header)
    v.addSubview(stack)
    header.snp.makeConstraints {
        $0.top.equalToSuperview().offset(12)
        $0.leading.equalToSuperview().offset(12)
    }
    stack.snp.makeConstraints {
        $0.top.equalTo(header.snp.bottom).offset(8)
        $0.leading.equalToSuperview().offset(12)
        $0.trailing.equalToSuperview().offset(-12)
        $0.bottom.lessThanOrEqualToSuperview().offset(-12)
    }
    return v
}

private func makeRow(price: String, amount: String) -> UIStackView {
    let priceLabel = UILabel()
    priceLabel.text = price
    priceLabel.font = AppFonts.regular(12)
    priceLabel.textColor = UIColor(hex: "#1B232A")

    let amountLabel = UILabel()
    amountLabel.text = amount
    amountLabel.font = AppFonts.regular(12)
    amountLabel.textColor = .appAccent
    amountLabel.textAlignment = .right

    let row = UIStackView(arrangedSubviews: [priceLabel, amountLabel])
    row.axis = .horizontal
    row.distribution = .equalSpacing
    row.snp.makeConstraints { $0.height.equalTo(18) }
    return row
}
