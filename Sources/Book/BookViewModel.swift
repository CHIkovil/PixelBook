//
//  BookViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import SwiftSoup
import RxCocoa
import RxSwift


protocol BookViewModelProtocol: AnyObject {
    var newCurrentPageRelay: PublishRelay<Int> {get}
    var closeBookRelay: PublishRelay<Int> { get }
    var currentPageDriver: Driver<Int?> { get }
    
    func viewWillAppear()
    func getPages() -> [AttributedString]
}

final class BookViewModel: BookViewModelProtocol {
    let newCurrentPageRelay = PublishRelay<Int>()
    let closeBookRelay = PublishRelay<Int>()
    private lazy var currentPageRelay = PublishRelay<Int?>()
    private(set) lazy var currentPageDriver = currentPageRelay.asDriver(
        onErrorJustReturn: nil)
    
    private let model: BookModel
    
    private let router: BookRouterProtocol
    private let disposeBag = DisposeBag()
    
    init(router: BookRouterProtocol, model: BookModel) {
        self.router = router
        self.model = model
        
        closeBookRelay
            .subscribe(onNext: { [weak self] pageIndex in
                guard let self = self else {return}
                self.closeBook(pageIndex)
            })
            .disposed(by: disposeBag)
        
        newCurrentPageRelay.subscribe(onNext: { [weak self] pageIndex in
            guard let self = self else {return}
            self.updateCurrentPage(pageIndex)
        })
        .disposed(by: disposeBag)
    }
    
    func viewWillAppear(){
        getCurrentPage()
    }
    
    func getPages() -> [AttributedString] {
        let currentPages: [AttributedString]
        if let pages =  PagesRequests.fetchOne(title: model.title, author: model.author) {
            currentPages = pages
        }else{
            let pages = BookParser.parseModelToPages(model)
            currentPages = pages
        }
        
        return currentPages
    }
}

private extension BookViewModel {
    func updateCurrentPage(_ pageIndex: Int) {
        BookRequests.updateState(book: self.model, currentPage: pageIndex)
    }
    
    func getCurrentPage() {
        UserRequests.update(UserModel(bookTitle: model.title, bookAuthor: model.author, isRead: true))
        NotificationCenter.default.post(name: .init(rawValue: AppConstants.newCurrentBookNotificationName), object: nil)
        guard let model = BookRequests.fetchOne(title: model.title, author: model.author) else{return}
        currentPageRelay.accept(model.currentPage)
    }
    
    func closeBook(_ pageIndex: Int) {
        BookRequests.updateState(book: self.model, currentPage: pageIndex)
        UserRequests.updateState(isRead: false)
        self.router.close()
    }
    
    
    
}
