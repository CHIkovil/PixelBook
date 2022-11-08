//
//  UIColor.swift
//  BlackBook
//
//  Created by Nikolas on 31.10.2022.
//
import UIKit

enum AppColor {
    static let mainText: UIColor = .white
    static let supportText: UIColor = UIColor(0x767676)
    static let background = UIColor(0x000000)
    static let contentBackground = #colorLiteral(red: 0.01240335125, green: 0.01240335125, blue: 0.01240335125, alpha: 1)
    static let contentBorder = UIColor(0x454545)
    static let active = UIColor(0xCCCCCC)
    static let unactive = UIColor(0x7A7A7A)
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
