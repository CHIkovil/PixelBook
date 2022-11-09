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
        static let contentOffset: CGFloat = 60
        static let fontSize: CGFloat = 20
    }
    
    var item = ""
    
    private lazy var textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = AppColor.contentBackground
        textView.textColor = AppColor.mainText
        textView.frame = self.view.bounds
        textView.font = UIFont(name: ".SFUIText", size: Constants.fontSize)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textView.textAlignment = .justified
        textView.layoutManager.usesDefaultHyphenation = true
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(textView)
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.contentOffset)
            $0.bottom.equalToSuperview().offset(-Constants.contentOffset)
            $0.width.equalToSuperview()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = item
    }
}
