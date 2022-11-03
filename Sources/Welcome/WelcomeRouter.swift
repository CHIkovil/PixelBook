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
        
    }
}

