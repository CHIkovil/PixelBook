//
//  WelcomeViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//
import RxCocoa
import RxSwift


protocol WelcomeViewModelProtocol: AnyObject {
    var quotesDriver: Driver<WelcomeViewModel.Quotes> { get }
    func moveToLibrary()
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    typealias Quotes = [(text: String, author: String)]
    
    private lazy var quotesRelay = PublishRelay<WelcomeViewModel.Quotes>()
    private(set) lazy var quotesDriver = quotesRelay.asDriver(
        onErrorJustReturn: [(text: "", author: "")]
        )
    
    private let router: WelcomeRouterProtocol
    
    init(router: WelcomeRouterProtocol) {
        self.router = router
    }
    
    func moveToLibrary() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.router.showLibrary()
        }
    }
}

private extension WelcomeViewModel {
    func updateState() {
        quotesRelay.accept([(text: "Classic – a book which people praise and don’t read.", author: "Mark Twain")])
    }
}
