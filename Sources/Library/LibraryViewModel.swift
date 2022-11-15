//
//  LibraryViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//
import RxCocoa
import RxSwift

protocol LibraryViewModelProtocol: AnyObject {
    func viewWillAppear()
    var selectedBookRelay: PublishRelay<BookModel> { get }
    var currentBookDriver: Driver<BookModel?> { get }
}

final class LibraryViewModel: LibraryViewModelProtocol {
    let selectedBookRelay = PublishRelay<BookModel>()
    private lazy var currentBookRelay = PublishRelay<BookModel?>()
    private(set) lazy var currentBookDriver = currentBookRelay.asDriver(
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
    
    func viewWillAppear(){
        updateState()
    }
}

private extension LibraryViewModel {
    func updateState() {
        guard let userModel = UserRequests.fetch(), let bookModel = BookRequests.fetchOne(title: userModel.bookTitle, author: userModel.bookAuthor) else{return}
        currentBookRelay.accept(bookModel)
    }
    
    func selectedBook(_ model: BookModel){
        self.router.showBook(model)
    }
}
