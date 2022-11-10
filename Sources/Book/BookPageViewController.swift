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
        textView.frame = self.view.bounds
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
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
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        style.alignment = .justified
        let attrs: [NSAttributedString.Key : Any] = [.kern: 0,
                                                     .font: UIFont(name: "Arial", size: Constants.fontSize) as Any,
                                                     .foregroundColor:
                                                        AppColor.readText,
                                                     .paragraphStyle : style]
        textView.attributedText = NSAttributedString(string: item, attributes: attrs)
    }
}
