//
//  Extensions.swift
//  BlackBook
//
//  Created by Nikolas on 13.11.2022.
//

import Foundation

extension Collection {
    var second: Element? { dropFirst().first }
}

func + (left: String?, right:String?) -> String? {
    return left != nil ? right != nil ? left! + right! : left : right
}
