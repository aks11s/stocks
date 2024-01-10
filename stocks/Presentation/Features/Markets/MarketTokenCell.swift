import UIKit
import SnapKit
import DGCharts

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

    // Mini sparkline chart — Figma: 142.5×31, uptrend green / downtrend red
    private lazy var chartView: LineChartView = {
        let c = LineChartView()
        c.isUserInteractionEnabled = false
        c.legend.enabled = false
        c.xAxis.enabled = false
        c.leftAxis.enabled = false
        c.rightAxis.enabled = false
        c.drawGridBackgroundEnabled = false
        c.drawBordersEnabled = false
        c.minOffset = 0
        c.setViewPortOffsets(left: 0, top: 4, right: 0, bottom: 4)
        return c
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
        [logoView, nameLabel, pairLabel, chartView,
         priceLabel, changeLabel, separator].forEach { contentView.addSubview($0) }
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

        // Chart spans from after the token name column to just before the price label
        chartView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(162)
            make.trailing.equalTo(priceLabel.snp.leading).offset(-8)
            make.height.equalTo(31)
            make.centerY.equalToSuperview()
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
            make.leading.trailing.bottom.equalToSuperview()
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
        configureChart(points: token.chartPoints, isUptrend: token.isUptrend)
    }

    private func configureChart(points: [Double], isUptrend: Bool) {
        let color = isUptrend ? UIColor.appAccent : UIColor.appRed

        let entries = points.enumerated().map { ChartDataEntry(x: Double($0.offset), y: $0.element) }

        // Pin x-axis to exact data range so the last point sits flush at the right edge
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = Double(entries.count - 1)

        let dataSet = LineChartDataSet(entries: entries)
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 1.5
        dataSet.setColor(color)
        dataSet.mode = .cubicBezier

        // Gradient fill below the line
        let gradientColors = [color.withAlphaComponent(0.4).cgColor,
                              color.withAlphaComponent(0.0).cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: gradientColors,
                                  locations: [0, 1])!
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
        dataSet.drawFilledEnabled = true

        chartView.data = LineChartData(dataSet: dataSet)
        chartView.notifyDataSetChanged()
    }
}
