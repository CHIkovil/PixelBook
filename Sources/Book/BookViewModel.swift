//
//  BookViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation


protocol BookViewModelProtocol: AnyObject {
    func getPages() -> [String]
}

final class BookViewModel: BookViewModelProtocol {
    private let model: BookModel
    private let router: BookRouterProtocol
    
    init(router: BookRouterProtocol, model: BookModel) {
        self.router = router
        self.model = model
    }
    
    func getPages() -> [String] {
        var pages: [String] = []
        let chapters = model.chapters
        chapters.forEach {chapter in
            let nextPages = chapter.text.split(separator: "\n").map {String($0)}
            pages += Array(nextPages)
        }
        return pages
    }
}
