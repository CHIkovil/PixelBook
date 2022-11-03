//
//  WelcomeViewController.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//

import UIKit
import RxSwift
import SnapKit



class WelcomeViewController: UIViewController {
    private enum Constants {
        static let appString = "BlackBook"
        static let labelWidth: CGFloat = 200
        static let labelHeight: CGFloat = 70
        static let labelFontSize: CGFloat = 35
    }

    lazy var appLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "edo", size: Constants.labelFontSize)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.text = Constants.appString
        label.textColor = AppColor.text
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        return label
    }()
    
    private var viewModel: WelcomeViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    func setup(viewModel: WelcomeViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.stateDriver
            .drive(onNext: { [weak self] state in
                self?.addUI(state)
            }).disposed(by: disposeBag)
    }
}

private extension WelcomeViewController {
    func addUI(_ state: WelcomeViewState) {
        view.backgroundColor = AppColor.background
        view.addSubview(appLabel)
        
        appLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(Constants.labelWidth)
            $0.height.equalTo(Constants.labelHeight)
        }
        
    }
}

