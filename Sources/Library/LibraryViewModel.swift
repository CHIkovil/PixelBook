//
//  LibraryViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//
import RxCocoa
import RxSwift

struct LibraryState {
    let currentBook: BookModel
    let isRead: Bool
}

protocol LibraryViewModelProtocol: AnyObject {
    func viewWillAppear(_ isCheckRead: Bool)
    var selectedBookRelay: PublishRelay<BookModel> { get }
    var сurrentBookDriver: Driver<LibraryState?> { get }
}

final class LibraryViewModel: LibraryViewModelProtocol {
    let selectedBookRelay = PublishRelay<BookModel>()
    private lazy var сurrentBookRelay = PublishRelay<LibraryState?>()
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
        if let userModel = UserRequests.fetch(), let bookModel = BookRequests.fetchOne(title: userModel.bookTitle, author: userModel.bookAuthor){
            if isCheckRead {
                if userModel.isRead {
                    self.selectedBook(bookModel)
                }
            }
            
            сurrentBookRelay.accept(LibraryState(currentBook: bookModel, isRead: userModel.isRead))
            
        }else{
            сurrentBookRelay.accept(nil)
        }
    }
    
    func selectedBook(_ model: BookModel){
        self.router.showBook(model)
    }
}
