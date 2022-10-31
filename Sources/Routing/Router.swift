//
//  Router.swift
//  BlackBook
//
//  Created by Nikolas on 31.10.2022.
//

import Foundation
import UIKit

protocol RouterProtocol {
    associatedtype VC: UIViewController
    var viewController: VC? { get }
}

class Router<U>: RouterProtocol where U: UIViewController {
    typealias VC = U
    weak var viewController: VC?

    init(viewController: VC) {
        self.viewController = viewController
    }
}
