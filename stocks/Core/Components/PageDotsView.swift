import UIKit

// Dot dimensions from Figma: 12.24×12.24pt each, gap ~8pt, total width 52pt
final class PageDotsView: UIView {

    private let count: Int
    private(set) var activeIndex: Int

    private var dotLayers: [CAShapeLayer] = []

    private enum Constants {
        static let dotSize: CGFloat  = 12
        static let dotGap:  CGFloat  = 8
    }

    init(count: Int, activeIndex: Int) {
        self.count       = count
        self.activeIndex = activeIndex
        let totalWidth   = CGFloat(count) * Constants.dotSize + CGFloat(count - 1) * Constants.dotGap
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: totalWidth, height: Constants.dotSize)))
        buildDots()
    }

    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: CGSize {
        let w = CGFloat(count) * Constants.dotSize + CGFloat(count - 1) * Constants.dotGap
        return CGSize(width: w, height: Constants.dotSize)
    }

    func setActiveIndex(_ index: Int, animated: Bool = true) {
        activeIndex = index
        let duration = animated ? 0.2 : 0
        dotLayers.enumerated().forEach { i, layer in
            let color = (i == index) ? UIColor.appAccent.cgColor : UIColor.appSurfaceCard.cgColor
            if animated {
                let anim = CABasicAnimation(keyPath: "fillColor")
                anim.fromValue = layer.fillColor
                anim.toValue   = color
                anim.duration  = duration
                layer.add(anim, forKey: "fillColor")
            }
            layer.fillColor = color
        }
    }

    private func buildDots() {
        isUserInteractionEnabled = false
        for i in 0..<count {
            let x      = CGFloat(i) * (Constants.dotSize + Constants.dotGap)
            let rect   = CGRect(x: x, y: 0, width: Constants.dotSize, height: Constants.dotSize)
            let shape  = CAShapeLayer()
            shape.path = UIBezierPath(ovalIn: rect).cgPath
            shape.fillColor = (i == activeIndex)
                ? UIColor.appAccent.cgColor
                : UIColor.appSurfaceCard.cgColor
            layer.addSublayer(shape)
            dotLayers.append(shape)
        }
    }
}
