//
//  BookViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

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
    
    private enum Constants {
        static let buttonSide: CGFloat = 30
        static let buttonOffset: CGFloat = 20
    }
    
    
    private var pagesController: BookPagesController?
    
    private lazy var contentViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        viewController.delegate = self
        return viewController
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.backgroundColor = AppColor.unactive
        button.layer.cornerRadius = 0.5 * Constants.buttonSide
        button.layer.masksToBounds = true
        return button
    }()
    
    override func loadView() {
        super.loadView()
        setupPagesController()
        setupContentController()
        
        view.insertSubview(closeButton, at: 1)
        
        closeButton.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(Constants.buttonOffset)
            $0.bottom.equalTo(view.snp.bottom).offset(-Constants.buttonOffset * 2)
            $0.height.equalTo(Constants.buttonSide)
            $0.width.equalTo(Constants.buttonSide)
        }
    }
    
    private var viewModel: BookViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    func setup(viewModel: BookViewModelProtocol) {
        self.viewModel = viewModel
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.closeBookRelay.accept(())
            }).disposed(by: disposeBag)
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
        textStyle.hyphenationFactor = 1.0
        textStyle.lineBreakMode = .byWordWrapping
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
        self.view.insertSubview(contentViewController.view, at: 0)
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
        
        pageViewController.isDoubleSided = true
        return .min
    }
}

