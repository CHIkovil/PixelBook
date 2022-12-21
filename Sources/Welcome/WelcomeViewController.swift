//
//  WelcomeViewController.swift
//  BlackBook
//
//  Created by Nikolas on 29.10.2022.
//

import UIKit
import RxSwift
import SnapKit



final class WelcomeViewController: UIViewController {
    private enum Constants {
        static let appString: String = "Pixel\nBook"
        static let labelWidth: CGFloat = 400
        static let labelHeight: CGFloat = 300
        static let labelFontSize: CGFloat = 45
    }

    lazy var appLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Silkscreen-Expanded", size: Constants.labelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.text = Constants.appString
        label.textColor = AppColor.mainText
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        label.numberOfLines = 0
        return label
    }()
    
    private var viewModel: WelcomeViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = AppColor.background
        view.addSubview(appLabel)
        
        appLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(Constants.labelWidth)
            $0.height.equalTo(Constants.labelHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.moveToLibrary()
    }
    
    func setup(viewModel: WelcomeViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.quotesDriver
            .drive(onNext: { [weak self] quotes in
                guard let self = self, let quotes = quotes else{return}
                self.showQuotes(quotes)
            }).disposed(by: disposeBag)
    }
}

private extension WelcomeViewController {
    func showQuotes(_ quotes: Quotes) {

    }
}

