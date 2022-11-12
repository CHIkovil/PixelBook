//
//  BookPageViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit
import SnapKit


class BookPageViewController: UIViewController {
    enum Constants {
        static let verticalOffset: CGFloat = 60
        static let horizontalOffset: CGFloat = 15
    }
    
    var item: NSAttributedString?
    
    private lazy var textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = AppColor.contentBackground
        textView.frame = self.view.bounds
        textView.textContainerInset = UIEdgeInsets(top: 0, left: Constants.horizontalOffset, bottom: 0, right: Constants.horizontalOffset)
        textView.layoutManager.usesDefaultHyphenation = true
        textView.isUserInteractionEnabled = true
        return textView
    }()
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(textView)
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.verticalOffset)
            $0.bottom.equalToSuperview().offset(-Constants.verticalOffset)
            $0.width.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let item = item else{return}
        textView.attributedText = item
    }
}
