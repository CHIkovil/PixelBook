//
//  LibraryRouter.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import Foundation

protocol LibraryRouterProtocol: AnyObject {
    func showBook(model: BookModel)
}

final class LibraryRouter: Router<LibraryViewController>, LibraryRouterProtocol {
    
    func showBook(model: BookModel) {
        
    }
}
