//
//  LibraryRouter.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import Foundation
import QuartzCore

protocol LibraryRouterProtocol: AnyObject {
    func showBook(_ model: BookModel)
}

final class LibraryRouter: Router<LibraryViewController>, LibraryRouterProtocol {
    
    func showBook(_ model: BookModel) {
        let controller = BookViewController()
        let router = BookRouter(viewController: controller)
        let viewModel = BookViewModel(router: router, model: model)
        controller.setup(viewModel: viewModel)
        controller.modalPresentationStyle = .overFullScreen
        viewController?.present(controller, animated: false)
    }
}
