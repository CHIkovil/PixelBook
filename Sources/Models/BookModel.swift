//
//  BookModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import Foundation

public struct BookModel {
    struct Chapter: Codable {
        let title: String
        let xhtml: String
    }

    let cover: Data?
    let title: String
    let author: String
    let chapters: [Chapter]
    var currentPage: Int
}

typealias Chapter = BookModel.Chapter

