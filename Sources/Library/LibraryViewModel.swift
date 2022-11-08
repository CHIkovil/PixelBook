//
//  LibraryViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import RxCocoa
import RxSwift

struct LibraryViewState {

}

protocol LibraryViewModelProtocol: AnyObject {
    var books: [BookModel] { get }
    func viewDidLoad()
    var stateDriver: Driver<LibraryViewState> { get }
    func selectedBook(index: Int)
}

final class LibraryViewModel: LibraryViewModelProtocol {
    private(set) lazy var books:[BookModel] = getBooks()
    private lazy var stateRelay = PublishRelay<LibraryViewState>()
    private(set) lazy var stateDriver = stateRelay.asDriver(
        onErrorJustReturn: LibraryViewState()
        )
    
    private let router: LibraryRouterProtocol
    
    init(router: LibraryRouterProtocol) {
        self.router = router
    }
    
    func viewDidLoad() {
        updateState()
    }
    
    func selectedBook(index: Int){
        self.router.showBook(model: books[index])
    }
}

private extension LibraryViewModel {
    func updateState() {
        stateRelay.accept(
            LibraryViewState()
        )
    }
    
    func getBooks() -> [BookModel] {
        guard let books = BookRequests.fetch() else {return []}
        return books.sorted {$0.title > $1.title}
    }
}
