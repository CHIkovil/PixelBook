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
    var item: NSAttributedString?
    
    private lazy var textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = AppColor.background
        textView.frame = self.view.bounds
        textView.textContainerInset = UIEdgeInsets(top: 0, left: PageConstants.widthOffset, bottom: 0, right: PageConstants.widthOffset)
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(textView)
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(PageConstants.heightOffset)
            $0.bottom.equalToSuperview().offset(-PageConstants.heightOffset)
            $0.width.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let item = item else{return}
        textView.attributedText = item
    }
}
