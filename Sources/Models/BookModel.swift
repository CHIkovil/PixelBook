//
//  BookModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import Foundation

typealias Chapter = BookModel.Chapter

public struct BookModel: Equatable {
    struct Chapter:Codable {
        let title: String
        let xhtml: String
    }
    
    let cover: Data?
    let title: String
    let author: String
    let chapters: [Chapter]
    var currentPage: Int
    
    public static func ==(lhs: BookModel, rhs: BookModel) -> Bool {
        return lhs.title == rhs.title && lhs.author == rhs.author
    }
}


