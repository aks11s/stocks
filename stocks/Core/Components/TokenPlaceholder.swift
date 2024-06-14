import UIKit

enum TokenPlaceholder {

    static func image(for ticker: String, size: CGFloat = 40) -> UIImage {
        let letter = String(ticker.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased()
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)

        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            UIColor.appSurfaceCard.setFill()
            ctx.cgContext.fillEllipse(in: bounds)

            let attrs: [NSAttributedString.Key: Any] = [
                .font: AppFonts.medium(size * 0.4),
                .foregroundColor: UIColor.appTextMuted
            ]
            let text = letter as NSString
            let textSize = text.size(withAttributes: attrs)
            let origin = CGPoint(
                x: (size - textSize.width) / 2,
                y: (size - textSize.height) / 2
            )
            text.draw(at: origin, withAttributes: attrs)
        }
    }
}
