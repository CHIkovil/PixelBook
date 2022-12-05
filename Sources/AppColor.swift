//
//  UIColor.swift
//  BlackBook
//
//  Created by Nikolas on 31.10.2022.
//
import UIKit

enum AppColor {
    static let readText: UIColor = #colorLiteral(red: 0.8745097518, green: 0.874509871, blue: 0.8788154125, alpha: 1)
    static let mainText: UIColor = #colorLiteral(red: 0.8745097518, green: 0.874509871, blue: 0.8788154125, alpha: 1)
    static let supportText: UIColor = UIColor(0x767676)
    static let background = #colorLiteral(red: 0.03789947554, green: 0.03618649021, blue: 0.04389099777, alpha: 1)
    static let contentBackground = #colorLiteral(red: 0.06175961345, green: 0.05897457153, blue: 0.07150980085, alpha: 1)
    static let contentBorder = #colorLiteral(red: 0.03789947554, green: 0.03618649021, blue: 0.04389099777, alpha: 1)
    static let active = #colorLiteral(red: 0.8745097518, green: 0.874509871, blue: 0.8788154125, alpha: 1)
    static let backgroundActive = UIColor(0x7A7A7A)
}


extension UIColor {

    convenience init(_ hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }

}
