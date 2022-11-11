//
//  BookViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation


protocol BookViewModelProtocol: AnyObject {
    func getModel() -> BookModel
}

final class BookViewModel: BookViewModelProtocol {
    private let model: BookModel
    private let router: BookRouterProtocol
    
    init(router: BookRouterProtocol, model: BookModel) {
        self.router = router
        self.model = model
    }
    
    func getModel() -> BookModel{
        return model
    }
}
