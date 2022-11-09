//
//  LibraryViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//
import RxCocoa
import RxSwift

protocol LibraryViewModelProtocol: AnyObject {
    var books: [BookModel] { get }
    var selectedBookRelay: PublishRelay<Int> { get }
}

final class LibraryViewModel: LibraryViewModelProtocol {
    private(set) lazy var books:[BookModel] = getBooks()
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
}

private extension LibraryViewModel {
    func getBooks() -> [BookModel] {
        guard let books = BookRequests.fetch() else {return []}
        return books.sorted {$0.title > $1.title}
    }
    
    func selectedBook(_ index: Int){
        self.router.showBook(model: books[index])
    }
}
