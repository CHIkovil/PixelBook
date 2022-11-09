//
//  BookViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit

final class BookViewController: UIViewController{
    
    private var modelController: PageModelController?
    
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        vc.delegate = self
        return vc
    }()
    
    private var viewModel: BookViewModelProtocol!
    
    override func loadView() {
        super.loadView()
        if let dataViewController = modelController?.viewControllerAtIndex(0) {
            let startingViewController: PageDataViewController = dataViewController
            let viewControllers = [startingViewController]
            pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        }
        
        pageViewController.dataSource = modelController
        self.view.addSubview(pageViewController.view)
    
        pageViewController.view.frame = self.view.bounds
        pageViewController.didMove(toParent: self)
    }
    
    func setup(viewModel: BookViewModelProtocol) {
        self.viewModel = viewModel
        self.modelController = PageModelController(viewModel.getPages())
    }
}

extension BookViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        
            let currentViewController = pageViewController.viewControllers?[0] ?? UIViewController()
            let currentViewControllers = [currentViewController]
            
            pageViewController.setViewControllers(currentViewControllers,
                                                  direction  : .forward,
                                                  animated   : true,
                                                  completion : { done in })
            
            pageViewController.isDoubleSided = false
            return .min
    }
}

