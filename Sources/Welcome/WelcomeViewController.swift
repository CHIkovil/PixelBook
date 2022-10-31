//
//  WelcomeViewController.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//

import UIKit
import RxSwift

enum WelcomeString {
    static let app = "BlackBook"
}


class WelcomeViewController: UIViewController {

    lazy var appLabel: UILabel = {
        let label = UILabel()
        label.text = WelcomeString.app
        label.backgroundColor = .clear
        label.textColor = AppColor.text
        label.font = UIFont(name: "edo", size: UIFont.labelFontSize)
        return label
    }()
    
    private var viewModel: WelcomeViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        viewModel?.viewDidLoad()
    }
    
    func setup(viewModel: WelcomeViewModelProtocol) {
        viewModel.stateDriver
            .drive(onNext: { [weak self] state in
                self?.addUI(state)
            }).disposed(by: disposeBag)
    }
}

private extension WelcomeViewController {
    func addUI(_ state: WelcomeViewState) {
        view.backgroundColor = AppColor.background
        
    }
}

