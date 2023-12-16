import UIKit
import SnapKit

// Convert / Spot / Margin / Fiat selector — Figma: 366×46, bg #161C22, active pill #1B232A
final class MarketFilterTabsView: UIView {

    var onTabSelected: ((Int) -> Void)?

    private let tabs = ["Convert", "Spot", "Margin", "Fiat"]
    private var selectedIndex = 1   // Spot is active by default

    private lazy var pill: UIView = {
        let v = UIView()
        v.backgroundColor = .appBackground
        v.layer.cornerRadius = 12
        return v
    }()

    private lazy var buttons: [UIButton] = tabs.enumerated().map { idx, title in
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = AppFonts.regular(14)
        b.tag = idx
        b.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        return b
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .appSurface
        layer.cornerRadius = 12
        setupViews()
        setupLayout()
        updateAppearance(animated: false)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupViews() {
        addSubview(pill)
        buttons.forEach { addSubview($0) }
    }

    private func setupLayout() {
        // 4 equal-width tabs across 366pt
        // Active pill: w=89 (366/4 + a bit of rounding), h=38, y=4
        for (idx, btn) in buttons.enumerated() {
            btn.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(4)
                make.leading.equalToSuperview().multipliedBy(1).offset(CGFloat(idx) * (366 / 4))
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Position pill under selected tab
        let tabWidth = bounds.width / 4
        pill.frame = CGRect(
            x: CGFloat(selectedIndex) * tabWidth + 4,
            y: 4,
            width: tabWidth - 8,
            height: bounds.height - 8
        )
    }

    // MARK: - Actions

    @objc private func tabTapped(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
        UIView.animate(withDuration: 0.2) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        updateAppearance(animated: true)
        onTabSelected?(selectedIndex)
    }

    private func updateAppearance(animated: Bool) {
        let update = {
            self.buttons.enumerated().forEach { idx, btn in
                btn.setTitleColor(idx == self.selectedIndex ? .appLabelMuted : .appTextSecondary, for: .normal)
            }
        }
        animated ? UIView.animate(withDuration: 0.2, animations: update) : update()
    }
}
