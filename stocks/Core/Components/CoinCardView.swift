import UIKit
import SnapKit

final class CoinCardView: UIView {

    // MARK: - Subviews

    private lazy var priceLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(16)
        return l
    }()

    private lazy var pairLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appBackground
        return l
    }()

    private lazy var changeLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(12)
        return l
    }()

    private lazy var logoView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    private lazy var logoLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(9)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private lazy var sparklineView = SparklineView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor(red: 22/255, green: 28/255, blue: 34/255, alpha: 1).cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 25
        layer.shadowOffset = CGSize(width: 0, height: 16)

        logoView.addSubview(logoLabel)
        [priceLabel, pairLabel, changeLabel, logoView, sparklineView].forEach { addSubview($0) }
    }

    private func setupLayout() {
        // price — top-left
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(10)
        }

        // pair — below price
        pairLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(42)
        }

        // change — right of pair
        changeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(88)
            make.top.equalToSuperview().offset(43)
        }

        // logo — top-right corner
        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(8)
            make.top.equalToSuperview().inset(8)
        }

        logoLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // sparkline — bottom
        sparklineView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.width.equalTo(142)
            make.height.equalTo(31)
        }
    }

    // MARK: - Configure

    func configure(price: String, pair: String, change: String, isUp: Bool, logoColor: UIColor, symbol: String) {
        let accent: UIColor = isUp ? .appAccent : .appRed
        priceLabel.text = price
        priceLabel.textColor = accent
        pairLabel.text = pair
        changeLabel.text = change
        changeLabel.textColor = accent
        logoView.backgroundColor = logoColor
        logoLabel.text = symbol
        sparklineView.configure(isUp: isUp)
    }
}

// MARK: - SparklineView

private final class SparklineView: UIView {

    private var isUp = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(isUp: Bool) {
        self.isUp = isUp
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let color: UIColor = isUp ? .appAccent : .appRed
        let fillColor = isUp
            ? UIColor(red: 94/255, green: 213/255, blue: 168/255, alpha: 0.15)
            : UIColor(red: 221/255, green: 75/255, blue: 75/255, alpha: 0.15)

        // Simple mock sparkline points
        let upPoints: [CGFloat]   = [1.0, 0.85, 0.75, 0.80, 0.60, 0.50, 0.55, 0.40, 0.30, 0.20, 0.10]
        let downPoints: [CGFloat] = [0.10, 0.20, 0.30, 0.25, 0.45, 0.55, 0.50, 0.65, 0.75, 0.85, 1.0]
        let pts = isUp ? upPoints : downPoints

        let w = rect.width
        let h = rect.height
        let step = w / CGFloat(pts.count - 1)

        let path = UIBezierPath()
        for (i, p) in pts.enumerated() {
            let x = CGFloat(i) * step
            let y = p * (h - 4) + 2
            i == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
        }

        // Fill area under line
        let fill = path.copy() as! UIBezierPath
        fill.addLine(to: CGPoint(x: w, y: h))
        fill.addLine(to: CGPoint(x: 0, y: h))
        fill.close()
        fillColor.setFill()
        fill.fill()

        // Draw line
        color.setStroke()
        path.lineWidth = 1.5
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        path.stroke()

        // Start dot
        let dotPt = CGPoint(x: 0, y: (pts.first ?? 0) * (h - 4) + 2)
        let dotRect = CGRect(x: dotPt.x - 3, y: dotPt.y - 3, width: 6, height: 6)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: dotRect)
    }
}
