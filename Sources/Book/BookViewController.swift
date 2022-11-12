//
//  BookViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit

final class BookViewController: UIViewController {
    
    private var pagesController: BookPagesController?
    
    private lazy var contentViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        viewController.delegate = self
        return viewController
    }()
    
    override func loadView() {
        super.loadView()
        setupPagesController()
        setupContentController()
    }
    
    private var viewModel: BookViewModelProtocol?
    
    func setup(viewModel: BookViewModelProtocol) {
        self.viewModel = viewModel
    }
}

private extension BookViewController {
    func setupTextAttrs() -> [NSAttributedString.Key : Any] {
        let universalTextSpacing: CGFloat = 7
        let textKern: CGFloat = 0
        let fontName: String = "Arial"
        let fontSize: CGFloat = 20
        let textFont: UIFont = UIFont(name: fontName, size: fontSize)!
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = universalTextSpacing
        style.paragraphSpacing = universalTextSpacing
        style.alignment = .justified
        
        let fontAttrs: [NSAttributedString.Key : Any] = [.kern: textKern,
                                                                .font: textFont as Any,
                                                                .foregroundColor:
                                                                    AppColor.readText,
                                                                .paragraphStyle:    style]
        return fontAttrs
    }
    
    func setupPagesController() {
        viewModel?.parseModelToPages(bounds: self.view.bounds, attrs: self.setupTextAttrs()) {[weak self] pages in
            guard let self = self else{return}
            self.pagesController = BookPagesController(pages)
        }
    }
    
    func setupContentController() {
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

