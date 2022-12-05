//
//  CollectionExt.swift
//  BlackBook
//
//  Created by Nikolas on 05.12.2022.
//

import Foundation

extension Collection {
    var second: Element? { dropFirst().first }
}
