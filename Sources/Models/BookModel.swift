//
//  BookModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import Foundation

public struct BookModel {
    let cover: Data?
    let title: String
    let author: String
    let pages: [AttributedString]
    var currentPage: Int
}

