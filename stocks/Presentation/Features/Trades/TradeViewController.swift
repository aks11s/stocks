import UIKit
import SnapKit

final class TradeViewController: UIViewController {

    private let viewModel: TradeViewModel

    // MARK: - Callbacks

    var onBack: (() -> Void)?

    // MARK: - Header

    private let headerView = UIView()

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "icon_chevron_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .appTextPrimary
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = .appAccent
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private lazy var avatarLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(14)
        l.textColor = .appBackground
        l.textAlignment = .center
        l.text = ProfileStorage.shared.username?.first.map { String($0).uppercased() } ?? "U"
        return l
    }()

    private lazy var searchButton: UIButton = makeIconButton(named: "icon_search")

    private lazy var starButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = .appAccent
        return b
    }()

    // MARK: - Price section

    private let priceSectionStack = UIStackView()

    private lazy var priceLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.bold(28)
        l.textColor = .appTextPrimary
        l.text = "—"
        return l
    }()

    private lazy var changeLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        return l
    }()

    private lazy var pairLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appLabelMuted
        return l
    }()

    // MARK: - Chart

    private let chartView = CandleChartView()

    private lazy var chartLoadingIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.color = .appAccent
        a.hidesWhenStopped = true
        return a
    }()

    // MARK: - Timeframe tabs

    private let timeframeTabsView = UIView()
    private var timeframeTabs: [UIButton] = []

    private let intervals: [(label: String, value: KlineInterval?)] = [
        ("1m", .oneMinute),
        ("5m", .fiveMinutes),
        ("15m", .fifteenMinutes),
        ("1d", .oneDay),
        ("More", nil)
    ]

    // MARK: - Buy / Sell

    private let buySellRow = UIStackView()

    private lazy var buyButton: UIButton = {
        let b = UIButton()
        b.setTitle("Buy", for: .normal)
        b.setTitleColor(.appButtonLabel, for: .normal)
        b.titleLabel?.font = AppFonts.regular(14)
        b.backgroundColor = .appAccent
        b.layer.shadowColor = UIColor.appAccent.withAlphaComponent(0.16).cgColor
        b.layer.shadowOffset = CGSize(width: 0, height: 8)
        b.layer.shadowRadius = 20
        b.layer.shadowOpacity = 1
        return b
    }()

    private lazy var sellButton: UIButton = {
        let b = UIButton()
        b.setTitle("Sell", for: .normal)
        b.setTitleColor(.appButtonLabel, for: .normal)
        b.titleLabel?.font = AppFonts.regular(14)
        b.backgroundColor = .appRed
        b.layer.shadowColor = UIColor.appRed.withAlphaComponent(0.16).cgColor
        b.layer.shadowOffset = CGSize(width: 0, height: 8)
        b.layer.shadowRadius = 20
        b.layer.shadowOpacity = 1
        return b
    }()

    // MARK: - Bottom section (white)

    private let bottomSection = UIView()
    private let segmentTabsRow = UIStackView()
    private var segmentButtons: [UIButton] = []
    private let orderBookView = TradeOrderBookView()

    private let segmentLabels = ["Open Order", "Order Books", "Market Trades"]
    private var activeSegment: Int = 1

    // MARK: - Favorite state

    private var isFavorite: Bool = false

    // MARK: - Init

    init(viewModel: TradeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        addSubviews()
        configureViews()
        applyLayout()
        bindViewModel()
        isFavorite = FavoritesStorage.shared.contains(viewModel.symbol)
        updateStarButton()
        viewModel.load()
    }

    // MARK: - Subview tree

    private func addSubviews() {
        // Header
        avatarView.addSubview(avatarLabel)
        [backButton, avatarView, searchButton, starButton].forEach { headerView.addSubview($0) }
        view.addSubview(headerView)

        // Price section
        view.addSubview(priceSectionStack)

        // Chart
        view.addSubview(chartView)
        view.addSubview(chartLoadingIndicator)

        // Timeframe tabs
        view.addSubview(timeframeTabsView)

        // Buy/Sell
        buySellRow.addArrangedSubview(buyButton)
        buySellRow.addArrangedSubview(sellButton)
        view.addSubview(buySellRow)

        // Bottom section
        bottomSection.addSubview(segmentTabsRow)
        bottomSection.addSubview(orderBookView)
        view.addSubview(bottomSection)
    }

    // MARK: - Configure views

    private func configureViews() {
        configureHeader()
        configurePriceSection()
        configureTimeframeTabs()
        configureBuySellRow()
        configureBottomSection()
    }

    private func configureHeader() {
        headerView.backgroundColor = .appBackground
        headerView.layer.shadowColor = UIColor(red: 22/255, green: 28/255, blue: 34/255, alpha: 1).cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 12)
        headerView.layer.shadowRadius = 16
        headerView.layer.shadowOpacity = 0.5
        starButton.addTarget(self, action: #selector(starTapped), for: .touchUpInside)
    }

    private func configurePriceSection() {
        let symbolParts = viewModel.symbol.components(separatedBy: "-")
        pairLabel.text = symbolParts.count == 2 ? "\(symbolParts[0])/\(symbolParts[1])" : viewModel.symbol

        let swapIcon = UIImageView(image: UIImage(systemName: "arrow.left.arrow.right"))
        swapIcon.tintColor = .appLabelMuted
        swapIcon.contentMode = .scaleAspectFit
        swapIcon.snp.makeConstraints { $0.width.height.equalTo(16) }

        let priceRow = UIStackView(arrangedSubviews: [priceLabel, changeLabel])
        priceRow.axis = .horizontal
        priceRow.spacing = 8
        priceRow.alignment = .center

        let pairRow = UIStackView(arrangedSubviews: [swapIcon, pairLabel])
        pairRow.axis = .horizontal
        pairRow.spacing = 4
        pairRow.alignment = .center

        priceSectionStack.axis = .vertical
        priceSectionStack.spacing = 4
        priceSectionStack.addArrangedSubview(priceRow)
        priceSectionStack.addArrangedSubview(pairRow)
    }

    private func configureTimeframeTabs() {
        timeframeTabsView.backgroundColor = .appSurfaceCard

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        timeframeTabsView.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        for (index, item) in intervals.enumerated() {
            let b = UIButton()
            b.setTitle(item.label, for: .normal)
            b.titleLabel?.font = AppFonts.regular(12)
            b.setTitleColor(index == 0 ? .appTextPrimary : .appTextSecondary, for: .normal)
            b.tag = index
            b.addTarget(self, action: #selector(timeframeTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(b)
            timeframeTabs.append(b)
        }
    }

    private func configureBuySellRow() {
        buySellRow.axis = .horizontal
        buySellRow.distribution = .fillEqually
    }

    private func configureBottomSection() {
        bottomSection.backgroundColor = .white

        segmentTabsRow.axis = .horizontal
        segmentTabsRow.distribution = .fillEqually

        for (index, title) in segmentLabels.enumerated() {
            let b = UIButton()
            b.setTitle(title, for: .normal)
            b.titleLabel?.font = AppFonts.regular(14)
            b.tag = index
            b.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
            segmentTabsRow.addArrangedSubview(b)
            segmentButtons.append(b)
        }

        updateSegmentAppearance()
    }

    // MARK: - Layout

    private func applyLayout() {
        avatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.centerY.equalTo(avatarView)
            $0.width.height.equalTo(44)
        }
        avatarView.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(4)
            $0.top.equalTo(headerView.safeAreaLayoutGuide).offset(8)
            $0.width.height.equalTo(36)
        }
        starButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalTo(avatarView)
            $0.width.height.equalTo(44)
        }
        searchButton.snp.makeConstraints {
            $0.trailing.equalTo(starButton.snp.leading).offset(-8)
            $0.centerY.equalTo(avatarView)
            $0.width.height.equalTo(44)
        }
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(51)
        }

        priceSectionStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Spacing.l)
            $0.top.equalTo(headerView.snp.bottom).offset(20)
        }

        timeframeTabsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buySellRow.snp.top)
            $0.height.equalTo(38)
        }

        chartView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(priceSectionStack.snp.bottom).offset(12)
            $0.bottom.equalTo(timeframeTabsView.snp.top)
        }

        chartLoadingIndicator.snp.makeConstraints { $0.center.equalTo(chartView) }

        buySellRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomSection.snp.top)
            $0.height.equalTo(48)
        }

        bottomSection.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(260)
        }

        segmentTabsRow.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        orderBookView.snp.makeConstraints {
            $0.top.equalTo(segmentTabsRow.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Bind

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.chartLoadingIndicator.startAnimating()

            case .loaded(let candles, let orderBook, let price, let changePct):
                self.chartLoadingIndicator.stopAnimating()
                self.chartView.configure(candles: candles)
                self.orderBookView.configure(orderBook: orderBook)
                self.priceLabel.text = self.formatPrice(price)
                self.changeLabel.text = String(format: "%+.2f%%", changePct)
                self.changeLabel.textColor = changePct >= 0 ? .appAccent : .appRed

            case .error:
                self.chartLoadingIndicator.stopAnimating()
            }
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        onBack?()
    }

    @objc private func starTapped() {
        if isFavorite {
            FavoritesStorage.shared.remove(viewModel.symbol)
        } else {
            FavoritesStorage.shared.add(viewModel.symbol)
        }
        isFavorite.toggle()
        updateStarButton()
    }

    @objc private func timeframeTapped(_ sender: UIButton) {
        let index = sender.tag
        guard let interval = intervals[index].value else { return }
        timeframeTabs.forEach { $0.setTitleColor(.appTextSecondary, for: .normal) }
        sender.setTitleColor(.appTextPrimary, for: .normal)
        viewModel.selectInterval(interval)
    }

    @objc private func segmentTapped(_ sender: UIButton) {
        activeSegment = sender.tag
        updateSegmentAppearance()
        orderBookView.isHidden = activeSegment != 1
    }

    // MARK: - Helpers

    private func updateStarButton() {
        let name = isFavorite ? "star.fill" : "star"
        starButton.setImage(UIImage(systemName: name), for: .normal)
    }

    private func updateSegmentAppearance() {
        for (index, btn) in segmentButtons.enumerated() {
            let isActive = index == activeSegment
            btn.setTitleColor(isActive ? UIColor(hex: "#1B232A") : .appTextMuted, for: .normal)
            btn.backgroundColor = isActive ? UIColor(hex: "#F1F4F6") : .white
        }
    }

    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

// MARK: - Factory

private func makeIconButton(named name: String) -> UIButton {
    let b = UIButton(type: .system)
    let img = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
    b.setImage(img, for: .normal)
    b.tintColor = .appAccent
    return b
}
