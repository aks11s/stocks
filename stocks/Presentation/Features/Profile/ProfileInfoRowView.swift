import UIKit
import SnapKit

final class ProfileInfoRowView: UIView {

    // Fired when the user taps "Add" on an empty field
    var onAddTap: (() -> Void)?

    // MARK: - Subviews

    private lazy var labelText: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appLabelMuted
        return l
    }()

    private lazy var valueText: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regular(14)
        l.textColor = .appTextSecondary
        return l
    }()

    // Shown instead of valueText when the field has no data yet
    private lazy var addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Add", for: .normal)
        b.setTitleColor(.appAccent, for: .normal)
        b.titleLabel?.font = AppFonts.regular(14)
        b.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        b.isHidden = true
        return b
    }()

    private lazy var arrowView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_arrow_right")?.withRenderingMode(.alwaysTemplate))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupViews() {
        [separator, labelText, valueText, addButton, arrowView].forEach { addSubview($0) }
    }

    private func setupLayout() {
        separator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        labelText.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        arrowView.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        valueText.snp.makeConstraints { make in
            make.trailing.equalTo(arrowView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(arrowView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - Configure

    func configure(label: String, value: String?) {
        labelText.text = label
        let hasValue = value != nil && !value!.isEmpty
        valueText.text = value
        valueText.isHidden = !hasValue
        addButton.isHidden = hasValue
    }

    // MARK: - Actions

    @objc private func addTapped() {
        onAddTap?()
    }
}
