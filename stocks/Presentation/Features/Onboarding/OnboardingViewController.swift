import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let pages = OnboardingPage.all
    private var currentIndex = 0

    // MARK: - Views

    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "onboarding_background"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var illustrationImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: pages[0].illustrationName))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // Fades the illustration into the content area below (Rectangle 21 in Figma)
    private lazy var gradientView = UIView()
    private let gradientLayer: CAGradientLayer = {
        let layer        = CAGradientLayer()
        layer.colors     = [UIColor.appSurface.withAlphaComponent(0).cgColor,
                            UIColor.appSurface.cgColor]
        layer.locations  = [0, 0.37]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint   = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    // Additional fade that starts higher — blends bottom of illustration into background (Rectangle 50)
    private lazy var bottomFadeView = UIView()
    private let bottomFadeLayer: CAGradientLayer = {
        let layer        = CAGradientLayer()
        layer.colors     = [UIColor.appBackground.withAlphaComponent(0).cgColor,
                            UIColor.appBackground.cgColor]
        layer.locations  = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint   = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()

    private lazy var bodyLabel: UILabel = {
        let lbl = UILabel()
        lbl.attributedText = makeAttr(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore.",
            font: AppFonts.regular(18),
            color: .appTextSecondary,
            alignment: .center,
            lineHeight: 28
        )
        lbl.numberOfLines = 0
        return lbl
    }()

    private lazy var pageDotsView = PageDotsView(count: pages.count, activeIndex: 0)

    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor     = .appAccent
        btn.layer.cornerRadius  = 16
        btn.layer.shadowColor   = UIColor.appAccent.withAlphaComponent(0.16).cgColor
        btn.layer.shadowOffset  = CGSize(width: 0, height: 20)
        btn.layer.shadowRadius  = 30
        btn.layer.shadowOpacity = 1
        btn.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        apply(page: pages[0], animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Frames must be updated here — bounds are not ready in viewDidLoad
        gradientLayer.frame    = gradientView.bounds
        bottomFadeLayer.frame  = bottomFadeView.bounds
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = .appBackground
        gradientView.layer.addSublayer(gradientLayer)
        bottomFadeView.layer.addSublayer(bottomFadeLayer)
        [backgroundImageView, illustrationImageView, bottomFadeView, gradientView,
         titleLabel, bodyLabel, pageDotsView, nextButton].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        // Background bleeds under the safe area on purpose — full-screen visual
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        illustrationImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(41)
            // y=93 is absolute from frame top in Figma (not relative to safe area)
            $0.top.equalToSuperview().offset(93)
            $0.width.equalToSuperview().multipliedBy(332.0 / 414.0)
            $0.height.equalToSuperview().multipliedBy(369.0 / 896.0)
        }

        // Rectangle 50: extra fade starting at y=336, 144pt tall — blends illustration bottom
        bottomFadeView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(336)
            $0.height.equalTo(144)
        }

        gradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(403.0 / 896.0)
        }

        // Build layout bottom-up so it adapts to any screen height
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(180)
            $0.height.equalTo(54)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
        }

        pageDotsView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 52, height: 12))
            $0.bottom.equalTo(nextButton.snp.top).offset(-41)
        }

        bodyLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.trailing.equalToSuperview().offset(-Spacing.l)
            $0.bottom.equalTo(pageDotsView.snp.top).offset(-41)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Spacing.l)
            $0.trailing.equalToSuperview().offset(-Spacing.l)
            $0.bottom.equalTo(bodyLabel.snp.top).offset(-Spacing.l)
        }
    }

    // MARK: - State

    private func apply(page: OnboardingPage, animated: Bool) {
        titleLabel.attributedText = makeAttr(page.title,
                                             font: AppFonts.regular(24),
                                             color: .appTextPrimary,
                                             alignment: .center)
        pageDotsView.setActiveIndex(page.dotIndex, animated: animated)

        let buttonTitle = page.dotIndex == pages.count - 1 ? "Get Started" : "Next"
        nextButton.setAttributedTitle(makeAttr(buttonTitle,
                                               font: AppFonts.regular(18),
                                               color: .appButtonLabel,
                                               alignment: .center), for: .normal)

        guard animated else {
            illustrationImageView.image = UIImage(named: page.illustrationName)
            return
        }

        UIView.transition(with: illustrationImageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve) {
            self.illustrationImageView.image = UIImage(named: page.illustrationName)
        }
    }

    // MARK: - Actions

    @objc private func nextTapped() {
        let nextIndex = currentIndex + 1
        if nextIndex < pages.count {
            currentIndex = nextIndex
            apply(page: pages[currentIndex], animated: true)
        } else {
            onFinish?()
        }
    }
}

// MARK: - Attributed string helper

private func makeAttr(
    _ text: String,
    font: UIFont,
    color: UIColor,
    alignment: NSTextAlignment,
    lineHeight: CGFloat? = nil
) -> NSAttributedString {
    let ps       = NSMutableParagraphStyle()
    ps.alignment = alignment
    if let lh = lineHeight {
        // Setting both min and max locks iOS to exact Figma line height
        ps.minimumLineHeight = lh
        ps.maximumLineHeight = lh
    }
    var attrs: [NSAttributedString.Key: Any] = [
        .font:            font,
        .foregroundColor: color,
        .kern:            font.pointSize * 0.0264,
        .paragraphStyle:  ps
    ]
    if let lh = lineHeight {
        // Compensates for vertical shift iOS applies when line height is fixed
        attrs[.baselineOffset] = (lh - font.lineHeight) / 2
    }
    return NSAttributedString(string: text, attributes: attrs)
}
