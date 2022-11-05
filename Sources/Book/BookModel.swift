//
//  BookModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import Foundation

struct BookModel {
    struct Chapter {
        let title: String
        let text: String
    }
    
    let cover: NSData?
    let title: String
    let author: String
    let chapter: [Chapter]  
}

typealias Chapter = BookModel.Chapter

