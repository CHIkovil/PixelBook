//
//  LibraryViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//
import RxCocoa
import RxSwift

protocol LibraryViewModelProtocol: AnyObject {
    var books: [BookModel]? { get }
    func reloadBooks()
    var selectedBookRelay: PublishRelay<Int> { get }
}

final class LibraryViewModel: LibraryViewModelProtocol {
    private(set) var books:[BookModel]?
    let selectedBookRelay = PublishRelay<Int>()

    
    private let router: LibraryRouterProtocol
    private let disposeBag = DisposeBag()
    
    init(router: LibraryRouterProtocol) {
        self.router = router
        selectedBookRelay
            .subscribe(onNext: { [weak self] index in
                guard let self = self else {return}
                self.selectedBook(index)
            })
            .disposed(by: disposeBag)
        
    }
    
    func reloadBooks() {
        guard let books = BookRequests.fetch() else {return}
        self.books = books.sorted {$0.title > $1.title}
    }
}

private extension LibraryViewModel {
    func selectedBook(_ index: Int){
        guard let books = books else{return}
        self.router.showBook(model: books[index])
    }
}
