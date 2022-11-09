//
//  BookViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit

final class BookViewController: UIViewController{
    
    private lazy var contentViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        viewController.delegate = self
        return viewController
    }()
    
    override func loadView() {
        super.loadView()
        if let viewController = pagesController?.viewControllerAtIndex(0) {
            let startingViewController: BookPageViewController = viewController
            let viewControllers = [startingViewController]
            contentViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        }
        
        contentViewController.dataSource = pagesController
        contentViewController.view.frame = self.view.bounds
        self.view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
    }
    
    private var pagesController: BookPagesController?
    
    func setup(viewModel: BookViewModelProtocol) {
        let pages = viewModel.getPages()
        self.pagesController = BookPagesController(pages)
    }
}

extension BookViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        
            let viewController = pageViewController.viewControllers?[0] ?? UIViewController()
            let viewControllers = [viewController]
            
            pageViewController.setViewControllers(viewControllers,
                                                  direction  : .forward,
                                                  animated   : true,
                                                  completion : { done in })
            
            pageViewController.isDoubleSided = false
            return .min
    }
}

