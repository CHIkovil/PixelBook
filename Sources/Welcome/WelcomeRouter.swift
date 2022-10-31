//
//  WelcomeRouter.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//

protocol WelcomeRouterProtocol: AnyObject {
    func showLibrary()
}

class WelcomeRouter: Router<WelcomeViewController>, WelcomeRouterProtocol {
    
    func showLibrary() {
        
    }
}

