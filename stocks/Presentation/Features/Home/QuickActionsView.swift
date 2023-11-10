import UIKit
import SnapKit

final class QuickActionsView: UIView {

    struct Item {
        let title: String
        let imageName: String
    }

    // Matches Figma layout exactly:
    // Row 1: Deposit(44,105), Referral(138,105), Grid Trading(223,105), Margin/Settings(337,115)
    // Row 2: Launchpad(37,185), Savings(138,185), Liquid Swap(223,185), More(327,185)
    private let items: [[Item]] = [
        [
            Item(title: "Deposit",      imageName: "menu_deposit"),
            Item(title: "Referral",     imageName: "menu_referral"),
            Item(title: "Grid",         imageName: "menu_grid"),
            Item(title: "Margin",       imageName: "icon_settings"),
        ],
        [
            Item(title: "Launchpad",    imageName: "menu_launchpad"),
            Item(title: "Savings",      imageName: "menu_savings"),
            Item(title: "Liquid Swap",  imageName: "menu_liquid"),
            Item(title: "More",         imageName: "menu_more"),
        ]
    ]

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrid()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupGrid() {
        backgroundColor = .appBackground

        let rows = UIStackView()
        rows.axis = .vertical
        rows.distribution = .fillEqually
        addSubview(rows)

        rows.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }

        for row in items {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            for item in row {
                rowStack.addArrangedSubview(makeItemView(item))
            }
            rows.addArrangedSubview(rowStack)
        }

        addSeparators()
    }

    private func makeItemView(_ item: Item) -> UIView {
        let container = UIView()

        let icon = UIImageView(image: UIImage(named: item.imageName))
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = item.title
        label.font = AppFonts.regular(12)
        label.textColor = .appLabelMuted
        label.textAlignment = .center

        [icon, label].forEach { container.addSubview($0) }

        // 44×44 container — matches Figma icon frame; SVG fills it via scaleAspectFit
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(4)
            make.width.height.equalTo(44)
        }

        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(2)
        }

        return container
    }

    private func addSeparators() {
        let hSep = UIView()
        hSep.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        addSubview(hSep)

        hSep.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        for i in 1...3 {
            let vSep = UIView()
            vSep.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            addSubview(vSep)

            vSep.snp.makeConstraints { make in
                make.width.equalTo(0.5)
                make.top.bottom.equalToSuperview()
                make.centerX.equalTo(self.snp.trailing).multipliedBy(CGFloat(i) / 4)
            }
        }
    }
}
