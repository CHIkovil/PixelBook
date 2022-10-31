//
//  UIColor.swift
//  BlackBook
//
//  Created by Nikolas on 31.10.2022.
//
import UIKit

enum AppColor {
    static let text: UIColor = .white
    static let background = UIColor(0x1E1E1E)
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
