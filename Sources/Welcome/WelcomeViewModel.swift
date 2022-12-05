//
//  WelcomeViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//
import RxCocoa
import RxSwift

typealias Quotes = [(text: String, author: String)]

protocol WelcomeViewModelProtocol: AnyObject {
    func viewDidLoad()
    var quotesDriver: Driver<Quotes?> { get }
    func moveToLibrary()
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    private lazy var quotesRelay = PublishRelay<Quotes?>()
    private(set) lazy var quotesDriver = quotesRelay.asDriver(
        onErrorJustReturn: nil)
    
    private let router: WelcomeRouterProtocol
    
    init(router: WelcomeRouterProtocol) {
        self.router = router
    }
    
    func viewDidLoad() {
        updateState()
    }
    
    func moveToLibrary() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {[weak self] in
            self?.router.showLibrary()
        }
    }
}

private extension WelcomeViewModel {
    func updateState() {
        let quotes =  [(text: "Classic – a book which people praise and don’t read.", author: "Mark Twain")]
        quotesRelay.accept(quotes)
    }
}
