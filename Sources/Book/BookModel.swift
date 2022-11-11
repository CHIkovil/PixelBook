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
}

extension BookModel: Hashable {
    public static func == (lhs: BookModel, rhs: BookModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine((title + author).replacingOccurrences(of: " ", with: "").lowercased())
    }
}

typealias Chapter = BookModel.Chapter

