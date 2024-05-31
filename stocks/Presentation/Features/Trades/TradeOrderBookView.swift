import UIKit
import SnapKit

final class TradeOrderBookView: UIView {

    // books5 gives us 5 levels each side
    private static let visibleRows = 5

    fileprivate enum Side { case bid, ask }

    // MARK: - Columns

    private let bidHeader = makeHeader("Bid")
    private let askHeader = makeHeader("Ask")
    private let bidStack  = makeColumnStack()
    private let askStack  = makeColumnStack()

    private var bidRows: [OrderBookRow] = []
    private var askRows: [OrderBookRow] = []

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
        populate(rows: bidRows, entries: bids)
        populate(rows: askRows, entries: asks)
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .white

        bidRows = (0..<Self.visibleRows).map { _ in OrderBookRow(side: .bid) }
        askRows = (0..<Self.visibleRows).map { _ in OrderBookRow(side: .ask) }
        bidRows.forEach { bidStack.addArrangedSubview($0) }
        askRows.forEach { askStack.addArrangedSubview($0) }

        let bidColumn = makeColumn(header: bidHeader, stack: bidStack)
        let askColumn = makeColumn(header: askHeader, stack: askStack)

        let separator = UIView()
        separator.backgroundColor = UIColor.appTextMuted.withAlphaComponent(0.2)

        let headerDivider = UIView()
        headerDivider.backgroundColor = UIColor.appTextMuted.withAlphaComponent(0.15)

        addSubview(bidColumn)
        addSubview(separator)
        addSubview(askColumn)
        addSubview(headerDivider)

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
        headerDivider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(bidHeader.snp.bottom).offset(6)
            $0.height.equalTo(1)
        }
    }

    // MARK: - Population

    private func populate(rows: [OrderBookRow], entries: [OrderBookEntry]) {
        let maxAmount = entries.map(\.amount).max() ?? 0
        for (index, row) in rows.enumerated() {
            if index < entries.count {
                let entry = entries[index]
                row.set(
                    price: formatPrice(entry.price),
                    amount: formatAmount(entry.amount),
                    ratio: maxAmount > 0 ? CGFloat(entry.amount / maxAmount) : 0
                )
            } else {
                row.clear()
            }
        }
    }

    // MARK: - Formatting

    private func formatPrice(_ value: Double) -> String {
        addThousandsSeparator(String(format: "%.2f", value))
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

// MARK: - Row

// a single book row: price on the left, amount on the right, with a depth bar
// behind it that grows from the right based on relative volume
private final class OrderBookRow: UIView {

    private let barView = UIView()
    private let priceLabel = UILabel()
    private let amountLabel = UILabel()
    private var ratio: CGFloat = 0

    init(side: TradeOrderBookView.Side) {
        super.init(frame: .zero)

        let amountColor: UIColor = side == .bid ? .appAccent : .appRed
        barView.backgroundColor = amountColor.withAlphaComponent(0.12)
        barView.isUserInteractionEnabled = false

        priceLabel.font = AppFonts.regular(12)
        priceLabel.textColor = .appBackground

        amountLabel.font = AppFonts.regular(12)
        amountLabel.textColor = amountColor
        amountLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [priceLabel, amountLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing

        addSubview(barView)
        addSubview(stack)

        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        snp.makeConstraints { $0.height.equalTo(18) }
    }

    required init?(coder: NSCoder) { fatalError() }

    func set(price: String, amount: String, ratio: CGFloat) {
        priceLabel.text = price
        amountLabel.text = amount
        self.ratio = ratio
        setNeedsLayout()
    }

    func clear() {
        priceLabel.text = "—"
        amountLabel.text = "—"
        ratio = 0
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let barWidth = bounds.width * ratio
        barView.frame = CGRect(x: bounds.width - barWidth, y: 0, width: barWidth, height: bounds.height)
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
        $0.top.equalToSuperview().offset(8)
        $0.leading.equalToSuperview().offset(12)
    }
    stack.snp.makeConstraints {
        $0.top.equalTo(header.snp.bottom).offset(12)
        $0.leading.equalToSuperview().offset(12)
        $0.trailing.equalToSuperview().offset(-12)
        $0.bottom.lessThanOrEqualToSuperview().offset(-10)
    }
    return v
}
