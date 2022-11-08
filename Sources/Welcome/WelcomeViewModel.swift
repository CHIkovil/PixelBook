//
//  WelcomeViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//
import RxCocoa
import RxSwift

struct WelcomeViewState {
    struct Quote {
        let text: String
        let author: String
    }
    
    let quotes: [Quote]
}

protocol WelcomeViewModelProtocol: AnyObject {
    func viewDidLoad()
    var stateDriver: Driver<WelcomeViewState> { get }
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    private lazy var stateRelay = PublishRelay<WelcomeViewState>()
    private(set) lazy var stateDriver = stateRelay.asDriver(
        onErrorJustReturn: WelcomeViewState(
            quotes: [WelcomeViewState.Quote(text: "", author: "")]
        )
    )
    
    private let router: WelcomeRouterProtocol
    
    init(router: WelcomeRouterProtocol) {
        self.router = router
    }
    
    func viewDidLoad() {
        updateState()
    }
}

private extension WelcomeViewModel {
    func updateState() {
        stateRelay.accept(
            WelcomeViewState(quotes: [WelcomeViewState.Quote(text: "Classic – a book which people praise and don’t read.", author: "Mark Twain")])
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.router.showLibrary()
        }
    }
}
