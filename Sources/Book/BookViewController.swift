//
//  BookViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit

typealias PageConstants = BookViewController.PageConstants
typealias Pages = BookViewController.Pages

final class BookViewController: UIViewController {
    
    struct Pages {
        let spine: [String: Int]
        let items: [NSAttributedString]
    }
    
    enum PageConstants {
        static let heightOffset: CGFloat = 60
        static let widthOffset: CGFloat = 15
    }
    
    
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
    func setupAttrs() -> (title: [NSAttributedString.Key : Any], text: [NSAttributedString.Key : Any]) {
        let universalTextSpacing: CGFloat = 7
        let titleFont:UIFont = UIFont(name: "Arial", size: 25)!
        let textFont: UIFont = UIFont(name: "Arial", size: 20)!
        
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.lineSpacing = universalTextSpacing
        titleStyle.paragraphSpacing = universalTextSpacing + 5
        titleStyle.alignment = .center
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.lineSpacing = universalTextSpacing
        textStyle.paragraphSpacing = universalTextSpacing
        textStyle.hyphenationFactor = 1
        textStyle.alignment = .justified
        
        let titleAttrs: [NSAttributedString.Key : Any] = [.font: titleFont as Any,
                                                          .foregroundColor:
                                                            AppColor.readText,
                                                          .paragraphStyle: titleStyle]
        
        let textAttrs: [NSAttributedString.Key : Any] = [.font: textFont as Any,
                                                         .foregroundColor:
                                                            AppColor.readText,
                                                         .paragraphStyle: textStyle]
        return (title: titleAttrs, text: textAttrs)
    }
    
    func setupPagesController() {
        var pageBounds = self.view.bounds
        pageBounds.size.width -= PageConstants.widthOffset * 2 + 20
        pageBounds.size.height -= PageConstants.heightOffset * 2 + 150
        
        let attrs = self.setupAttrs()
        
        viewModel?.parseModelToPages(bounds: pageBounds, attrs: attrs) {[weak self] pages in
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

