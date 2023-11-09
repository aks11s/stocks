import UIKit

extension UIColor {
    static let appBackground    = UIColor(hex: "#1B232A")
    static let appSurface       = UIColor(hex: "#161C22")
    static let appSurfaceCard   = UIColor(hex: "#252E35")
    static let appAccent        = UIColor(hex: "#5ED5A8")
    static let appGold          = UIColor(hex: "#FCBD68")
    static let appTextPrimary   = UIColor.white
    static let appTextSecondary = UIColor(hex: "#777777")
    static let appButtonLabel   = UIColor(hex: "#171D22")
    static let appTextMuted     = UIColor(hex: "#A7AFB7")
    static let appRed           = UIColor(hex: "#DD4B4B")
    static let appLabelMuted    = UIColor(hex: "#C1C7CD")

    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8)  & 0xFF) / 255
        let b = CGFloat(rgb         & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
