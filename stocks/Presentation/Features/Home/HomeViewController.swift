import UIKit
import SnapKit

final class HomeViewController: UIViewController {

    // MARK: - Mock data

    private struct CoinMock {
        let price: String; let pair: String; let change: String
        let isUp: Bool; let color: UIColor; let symbol: String
    }

    // "Recent Coin" row — Figma: MFT(green), REN(red), BTC(green)
    private let recentCoins: [CoinMock] = [
        CoinMock(price: "40,059.83", pair: "MFT/BUSD", change: "+0.81%", isUp: true,  color: UIColor(hex: "#7833F6"), symbol: "M"),
        CoinMock(price: "2,059.83",  pair: "REN/BUSD", change: "-0.81%", isUp: false, color: UIColor(hex: "#001E3D"), symbol: "R"),
        CoinMock(price: "40,059.83", pair: "BTC/BUSD", change: "+0.81%", isUp: true,  color: UIColor(hex: "#F7931A"), symbol: "₿"),
    ]

    // "Top Coins" row — Figma: BTC(green), SOL(red), BTC(green)
    private let topCoins: [CoinMock] = [
        CoinMock(price: "40,059.83", pair: "BTC/BUSD", change: "+0.81%", isUp: true,  color: UIColor(hex: "#F7931A"), symbol: "₿"),
        CoinMock(price: "2,059.83",  pair: "SOL/BUSD", change: "-0.81%", isUp: false, color: UIColor(hex: "#2A5ADA"), symbol: "S"),
        CoinMock(price: "40,059.83", pair: "BTC/BUSD", change: "+0.81%", isUp: true,  color: UIColor(hex: "#F7931A"), symbol: "₿"),
    ]

    // MARK: - Subviews

    private lazy var headerView = HomeHeaderView()
    private lazy var quickActionsView = QuickActionsView()

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    private lazy var p2pCard: FeatureCardView = {
        let v = FeatureCardView()
        v.configure(title: "P2P Trading",
                    subtitle: "Bank Transfer, Paypal Revolut...",
                    icon: UIImage(named: "card_rocket"))
        return v
    }()

    private lazy var creditCard: FeatureCardView = {
        let v = FeatureCardView()
        v.configure(title: "Credit/Debit Card",
                    subtitle: "Visa, Mastercard",
                    icon: UIImage(named: "card_credit"))
        return v
    }()

    private lazy var recentCoinLabel  = makeSectionLabel("Recent Coin")
    private lazy var topCoinLabel     = makeSectionLabel("Top Coins")
    private lazy var recentScrollView = makeHorizontalCoinScroll(coins: recentCoins)
    private lazy var topScrollView    = makeHorizontalCoinScroll(coins: topCoins)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupLayout()
    }

    // MARK: - Setup

    private func setupViews() {
        headerView.onAvatarTap = { [weak self] in
            let profile = ProfileViewController()
            profile.modalPresentationStyle = .fullScreen
            self?.present(profile, animated: true)
        }

        [headerView, quickActionsView].forEach { view.addSubview($0) }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [p2pCard, creditCard,
         recentCoinLabel, recentScrollView,
         topCoinLabel, topScrollView].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        // Header: top of view → extends behind status bar; height = safeArea.top + 51pt
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(51)
        }

        quickActionsView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(168)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(quickActionsView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            // Bottom pinned to safeArea so content doesn't hide behind tab bar
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        // P2P card: 21pt from top (screen y=284, dark section ends at y=263 → 284-263=21)
        p2pCard.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(21)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(78)
        }

        // Credit card: 8pt gap (screen y=370, p2p ends at y=362 → 370-362=8)
        creditCard.snp.makeConstraints { make in
            make.top.equalTo(p2pCard.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(78)
        }

        // "Recent Coin" label: 27pt gap (screen y=475, credit ends at 448 → 475-448=27)
        recentCoinLabel.snp.makeConstraints { make in
            make.top.equalTo(creditCard.snp.bottom).offset(27)
            make.leading.equalToSuperview().inset(24)
        }

        // Recent coins horizontal scroll: 16pt gap (38pt from group top, label h=22 → 38-22=16)
        recentScrollView.snp.makeConstraints { make in
            make.top.equalTo(recentCoinLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(24)
            make.trailing.equalToSuperview()
            make.height.equalTo(118)
        }

        // "Top Coins" label: 30pt gap (186-(38+118)=30 within content group)
        topCoinLabel.snp.makeConstraints { make in
            make.top.equalTo(recentScrollView.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(24)
        }

        topScrollView.snp.makeConstraints { make in
            make.top.equalTo(topCoinLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(24)
            make.trailing.equalToSuperview()
            make.height.equalTo(118)
            make.bottom.equalToSuperview().inset(24)
        }
    }

    // MARK: - Helpers

    private func makeSectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.attributedText = NSAttributedString(string: text, attributes: [
            .font: AppFonts.bold(18),
            .foregroundColor: UIColor.appBackground,
            .kern: 18 * 0.0264,
        ])
        return l
    }

    /// Horizontal scroll containing coin cards at their native 163×118pt size.
    /// Cards peek off the right edge exactly as in Figma (content width = 505pt).
    private func makeHorizontalCoinScroll(coins: [CoinMock]) -> UIScrollView {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.clipsToBounds = false   // allow cards to visually overflow the scroll frame

        var prevView: UIView? = nil
        for (i, coin) in coins.enumerated() {
            let card = CoinCardView()
            card.configure(price: coin.price, pair: coin.pair, change: coin.change,
                           isUp: coin.isUp, logoColor: coin.color, symbol: coin.symbol)
            sv.addSubview(card)

            card.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.width.equalTo(163)
                make.height.equalTo(118)
                if let prev = prevView {
                    make.leading.equalTo(prev.snp.trailing).offset(8)
                } else {
                    make.leading.equalToSuperview()
                }
                if i == coins.count - 1 {
                    make.trailing.equalToSuperview()
                }
            }
            prevView = card
        }

        return sv
    }
}
