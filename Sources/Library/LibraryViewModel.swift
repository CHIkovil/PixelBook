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
    func viewDidLoad()
    var stateDriver: Driver<LibraryViewState> { get }
    func selectedBook(model: BookModel?)
}

final class LibraryViewModel: LibraryViewModelProtocol {
    
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
    
    func selectedBook(model: BookModel?){
        guard let book = model else{return}
        self.router.showBook()
    }
}

private extension LibraryViewModel {
    func updateState() {
        stateRelay.accept(
            LibraryViewState()
        )
    }
}
