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

typealias BookConfig = BookViewController.Config

final class BookViewController: UIViewController {
    
     enum Config {
        struct Config{
            let visibleScreenSize: CGRect
            let titleAttributes: [NSAttributedString.Key : Any]
            let textAttributes: [NSAttributedString.Key : Any]
        }
        
        static let value: Config = {
            var visibleScreenSize: CGRect = UIScreen.main.bounds
            visibleScreenSize.size.width -= PageConstants.widthOffset * 2
            visibleScreenSize.size.height -= PageConstants.heightOffset * 2 + 250
            
            let universalTextSpacing: CGFloat = 10
            let titleFont: UIFont = UIFont(name: AppConstants.textFontName, size: 25)!
            let textFont: UIFont = UIFont(name: AppConstants.textFontName, size: 20)!
            
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.lineSpacing = universalTextSpacing
            titleStyle.paragraphSpacing = universalTextSpacing * 2
            titleStyle.alignment = .center
            
            let textStyle = NSMutableParagraphStyle()
            textStyle.lineSpacing = universalTextSpacing
            textStyle.hyphenationFactor = 1.0
            textStyle.firstLineHeadIndent = 20
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
            
   
            
            return Config(visibleScreenSize: visibleScreenSize,
                          titleAttributes: titleAttrs,
                          textAttributes: textAttrs)
        }()
    }
    
    private enum Constants {
        static let buttonSide: CGFloat = 40
        static let buttonOffset: CGFloat = 25
        static let backImageName: String = "back"
    }
    
    private var pagesController: BookPagesController?
    
    private lazy var contentViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        viewController.delegate = self
        viewController.isDoubleSided = true
        return viewController
    }()
    
    private lazy var notificationView: NotificationView = {
        let view = NotificationView()
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Constants.backImageName)?.inverseImage(cgResult: false)?.resizeImage(CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate), for: .normal)
   
        button.tintColor = AppColor.backgroundActive
        button.backgroundColor = AppColor.background
        button.layer.cornerRadius = 0.5 * Constants.buttonSide
        button.layer.borderColor = AppColor.background.cgColor
        button.layer.borderWidth = AppConstants.contentBorderWidth
        button.layer.masksToBounds = true
        return button
    }()
    
    override func loadView() {
        super.loadView()
        setupPagesController()
        setupContentController()
        
        view.insertSubview(notificationView, at: 1)
        view.insertSubview(closeButton, at: 1)
        
        closeButton.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(Constants.buttonOffset)
            $0.bottom.equalTo(view.snp.bottom).offset(-Constants.buttonOffset)
            $0.height.equalTo(Constants.buttonSide)
            $0.width.equalTo(Constants.buttonSide)
        }
        
        notificationView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(AppConstants.topContentOffset - AppConstants.notificationViewHeight)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(AppConstants.notificationViewHeight)
            $0.width.equalTo(AppConstants.notificationViewWidth)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    private var viewModel: BookViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup(viewModel: BookViewModelProtocol) {
        self.viewModel = viewModel
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let pageIndex = self.getCurrentPageIndex() else{return}
                self.viewModel?.closeBookRelay.accept(pageIndex)
            }).disposed(by: disposeBag)
        
        viewModel.currentPageDriver
            .drive(onNext: { [weak self] pageIndex in
                guard let self = self , let pageIndex = pageIndex else{return}
                self.setCurrentPageIndex(pageIndex)
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didNewBook(notification:)),
                                               name: .init(rawValue: AppConstants.newBookNotificationName),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didRepeatedBook(notification:)),
                                               name: .init(rawValue: AppConstants.repeatedBookNotificationName),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didAppClose(notification:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
}

private extension BookViewController {
    @objc func didNewBook(notification: Notification){
        guard let pageIndex = self.getCurrentPageIndex() else{return}
        self.viewModel?.closeBookRelay.accept(pageIndex)
    }
    
    @objc func didRepeatedBook(notification: Notification){
        notificationView.setup(.repeated, alpha: 1)
    }
    
    @objc func didAppClose(notification: Notification){
        guard let pageIndex = self.getCurrentPageIndex() else{return}
        self.viewModel?.newCurrentPageRelay.accept(pageIndex)
    }
    
    func setupPagesController() {
        guard let pages = viewModel?.getPages() else{return}
        self.pagesController = BookPagesController(pages)
    }
    
    func setupContentController() {        
        contentViewController.dataSource = pagesController
        contentViewController.view.frame = self.view.bounds
        self.view.insertSubview(contentViewController.view, at: 0)
        contentViewController.didMove(toParent: self)
    }
    
    func setCurrentPageIndex(_ pageIndex: Int){
        guard let continuationViewController = self.pagesController?.viewControllerAtIndex(pageIndex)  else{return}
        self.contentViewController.setViewControllers([continuationViewController], direction: .forward, animated: false, completion: {done in })
    }
    
    func getCurrentPageIndex() -> Int?{
        guard let vc = self.contentViewController.viewControllers?.first as? BookPageViewController, let pageIndex = self.pagesController?.indexOfViewController(vc) else{return nil}
        return pageIndex
    }
    
}

extension BookViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        return .min
    }
}

