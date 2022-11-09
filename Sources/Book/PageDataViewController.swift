//
//  PageDataViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit


class PageDataViewController: UIViewController {
    var data = ""
    
    private lazy var textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = AppColor.contentBackground
        textView.textColor = AppColor.mainText
        textView.frame = self.view.bounds
        return textView
    }()
    
    override func viewDidLoad() {
        self.view.addSubview(textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = data
    }
}
