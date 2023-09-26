import UIKit

enum AppFonts {
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: "NeueMontreal-Regular", size: size)
            ?? .systemFont(ofSize: size, weight: .regular)
    }

    static func medium(_ size: CGFloat) -> UIFont {
        UIFont(name: "NeueMontreal-Medium", size: size)
            ?? .systemFont(ofSize: size, weight: .medium)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "NeueMontreal-Bold", size: size)
            ?? .systemFont(ofSize: size, weight: .bold)
    }
}
