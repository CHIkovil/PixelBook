//
//  LibraryViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//
import RxCocoa
import RxSwift

protocol LibraryViewModelProtocol: AnyObject {
    var selectedBookRelay: PublishRelay<BookModel> { get }
}

final class LibraryViewModel: LibraryViewModelProtocol {
    let selectedBookRelay = PublishRelay<BookModel>()

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
}

private extension LibraryViewModel {
    func selectedBook(_ model: BookModel){
        self.router.showBook(model)
    }
}
