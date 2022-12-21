//
//  BookConfig.swift
//  BlackBook
//
//  Created by Nikolas on 06.12.2022.
//

import Foundation
import UIKit

enum BookConfig {
   struct Config{
       let visibleScreenSize: CGRect
       let titleAttributes: [NSAttributedString.Key : Any]
       let textAttributes: [NSAttributedString.Key : Any]
   }
   
   static let value: Config = {
       var visibleScreenSize: CGRect = UIScreen.main.bounds
       visibleScreenSize.size.width -= PageConstants.widthOffset * 2
       visibleScreenSize.size.height -= PageConstants.heightOffset * 2 + 250
       
       let universalTextSpacing: CGFloat = 10
       let titleFont: UIFont = UIFont(name: AppConstants.textFontName, size: 25)!
       let textFont: UIFont = UIFont(name: AppConstants.textFontName, size: 20)!
       
       let titleStyle = NSMutableParagraphStyle()
       titleStyle.lineSpacing = universalTextSpacing
       titleStyle.paragraphSpacing = universalTextSpacing * 2
       titleStyle.alignment = .center
       
       let textStyle = NSMutableParagraphStyle()
       textStyle.lineSpacing = universalTextSpacing
       textStyle.hyphenationFactor = 1.0
       textStyle.firstLineHeadIndent = 20
       textStyle.lineBreakMode = .byWordWrapping
       textStyle.alignment = .justified
       
       let titleAttrs: [NSAttributedString.Key : Any] = [.font: titleFont as Any,
                                                        .foregroundColor:
                                                           AppColor.active,
                                                        .paragraphStyle: titleStyle]
       
       let textAttrs: [NSAttributedString.Key : Any] = [.font: textFont as Any,
                                                        .foregroundColor:
                                                           AppColor.active,
                                                        .paragraphStyle: textStyle]
       

       
       return Config(visibleScreenSize: visibleScreenSize,
                     titleAttributes: titleAttrs,
                     textAttributes: textAttrs)
   }()
}
