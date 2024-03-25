import UIKit
import DGCharts
import SnapKit

final class CandleChartView: UIView {

    private let chartView = CandleStickChartView()
    private let gradientOverlay = UIView()
    private let gradientLayer = CAGradientLayer()
    private let dateFormatter = CandleXAxisFormatter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func configure(candles: [Candle]) {
        dateFormatter.timestamps = candles.map { $0.timestamp }

        let entries = candles.enumerated().map { index, c in
            CandleChartDataEntry(x: Double(index), shadowH: c.high, shadowL: c.low, open: c.open, close: c.close)
        }

        let dataSet = CandleChartDataSet(entries: entries)
        dataSet.increasingColor        = .appAccent
        dataSet.increasingFilled       = true
        dataSet.decreasingColor        = .appRed
        dataSet.decreasingFilled       = true
        dataSet.shadowColorSameAsCandle = true
        dataSet.shadowWidth            = 1
        dataSet.drawValuesEnabled      = false
        dataSet.drawIconsEnabled       = false

        chartView.data = CandleChartData(dataSet: dataSet)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlay.bounds
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        setupChart()
        setupGradient()

        addSubview(chartView)
        addSubview(gradientOverlay)

        chartView.snp.makeConstraints { $0.edges.equalToSuperview() }
        gradientOverlay.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.35)
        }
        gradientOverlay.isUserInteractionEnabled = false
        gradientOverlay.layer.addSublayer(gradientLayer)
    }

    private func setupChart() {
        chartView.backgroundColor          = .appBackground
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled        = false
        chartView.legend.enabled            = false
        chartView.chartDescription.enabled  = false
        chartView.minOffset                 = 0

        chartView.leftAxis.enabled = false

        let right = chartView.rightAxis
        right.labelTextColor       = .appTextSecondary
        right.labelFont            = AppFonts.regular(10)
        right.drawGridLinesEnabled = false
        right.drawAxisLineEnabled  = false
        right.labelCount           = 5
        right.labelPosition        = .outsideChart

        let x = chartView.xAxis
        x.labelPosition       = .bottom
        x.labelTextColor      = .appTextSecondary
        x.labelFont           = AppFonts.regular(10)
        x.drawGridLinesEnabled = false
        x.drawAxisLineEnabled  = false
        x.labelCount           = 4
        x.valueFormatter       = dateFormatter
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.appBackground.withAlphaComponent(0).cgColor,
            UIColor.appBackground.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
    }
}

// MARK: - X-Axis formatter

private final class CandleXAxisFormatter: NSObject, AxisValueFormatter {
    var timestamps: [Int64] = []

    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let i = Int(value)
        guard i >= 0, i < timestamps.count else { return "" }
        let date = Date(timeIntervalSince1970: Double(timestamps[i]) / 1000)
        return df.string(from: date)
    }
}
