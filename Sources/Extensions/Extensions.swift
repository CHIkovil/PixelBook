//
//  Extesions.swift
//  BlackBook
//
//  Created by Nikolas on 12.11.2022.
//

import Foundation
import UIKit

extension UITextView {
    func numberOfCharactersThatFitTextView() -> Int {
        let fontRef = CTFontCreateWithName(font!.fontName as CFString, font!.pointSize, nil)
        let attributes = [kCTFontAttributeName : fontRef]
        let attributedString = NSAttributedString(string: text!, attributes: attributes as [NSAttributedString.Key : Any])
        let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)

        var characterFitRange: CFRange = CFRange()

        CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), nil, CGSize(width: bounds.size.width, height: bounds.size.height), &characterFitRange)
        return Int(characterFitRange.length)

    }
}

extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
}
