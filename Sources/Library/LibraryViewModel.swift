//
//  LibraryViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//
import RxCocoa
import RxSwift

protocol LibraryViewModelProtocol: AnyObject {
    func viewWillAppear(_ isCheckRead: Bool)
    var selectedBookRelay: PublishRelay<BookModel> { get }
    var сurrentBookDriver: Driver<BookModel?> { get }
}

final class LibraryViewModel: LibraryViewModelProtocol {
    let selectedBookRelay = PublishRelay<BookModel>()
    private lazy var сurrentBookRelay = PublishRelay<BookModel?>()
    private(set) lazy var сurrentBookDriver = сurrentBookRelay.asDriver(
        onErrorJustReturn: nil)

    private let router: LibraryRouterProtocol
    private let disposeBag = DisposeBag()
    
    init(router: LibraryRouterProtocol) {
        self.router = router
        selectedBookRelay
            .subscribe(onNext: { [weak self] model in
                guard let self = self else {return}
                self.selectedBook(model)
            })
            .disposed(by: disposeBag)
    }
    
    func viewWillAppear(_ isCheckRead: Bool){
        updateState(isCheckRead)
    }
}

private extension LibraryViewModel {
    func updateState(_ isCheckRead: Bool) {
        guard let userModel = UserRequests.fetch(), let bookModel = BookRequests.fetchOne(title: userModel.bookTitle, author: userModel.bookAuthor) else{return}
        
        if isCheckRead {
            if userModel.isRead {
                self.selectedBook(bookModel)
            }
        }
        
        сurrentBookRelay.accept(bookModel)
    }
    
    func selectedBook(_ model: BookModel){
        self.router.showBook(model)
    }
}
