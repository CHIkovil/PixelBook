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
    var item: AttributedString?
    
    private lazy var textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = AppColor.background
        textView.frame = self.view.bounds
        textView.textContainerInset = UIEdgeInsets(top: PageConstants.heightOffset, left: PageConstants.widthOffset, bottom: PageConstants.heightOffset, right: PageConstants.widthOffset)
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(textView)
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let item = item else{return}
        textView.attributedText = item.attributedString
    }
}
