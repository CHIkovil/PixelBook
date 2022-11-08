//
//  WelcomeRouter.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//

protocol WelcomeRouterProtocol: AnyObject {
    func showLibrary()
}

final class WelcomeRouter: Router<WelcomeViewController>, WelcomeRouterProtocol {
    
    func showLibrary() {
        let controller = LibraryViewController()
        let router = LibraryRouter(viewController: controller)
        let viewModel = LibraryViewModel(router: router)
        controller.setup(viewModel: viewModel)
        controller.modalPresentationStyle = .overFullScreen
        viewController?.present(controller, animated: true)
    }
}

