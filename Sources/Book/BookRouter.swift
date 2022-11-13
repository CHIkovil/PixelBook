//
//  BookRouter.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation

protocol BookRouterProtocol: AnyObject {
    func close()
}

final class BookRouter: Router<BookViewController>, BookRouterProtocol {
    
    func close() {
        viewController?.dismiss(animated: false)
    }
}
