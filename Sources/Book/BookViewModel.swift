//
//  BookViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import UIKit
import SwiftSoup
import DTCoreText


protocol BookViewModelProtocol: AnyObject {
    func parseModelToPages(bounds: CGRect, attrs: [NSAttributedString.Key : Any], callback: @escaping([NSAttributedString]) -> Void)
}

final class BookViewModel: BookViewModelProtocol {
    private let model: BookModel
    private let router: BookRouterProtocol
    
    init(router: BookRouterProtocol, model: BookModel) {
        self.router = router
        self.model = model
    }
    
    
    func parseModelToPages(bounds: CGRect, attrs: [NSAttributedString.Key : Any], callback: @escaping([NSAttributedString]) -> Void){
        var paragraphs: [String] = []
        model.chapters.forEach { chapter in
            let parsedChapter = try? SwiftSoup.parse(chapter.xhtml)
            let p = try? parsedChapter?.select("p").eachText()
            guard let p = p else{return}
            paragraphs += p
        }
        
        let text: String = paragraphs.joined(separator: "\n")
        let attributedString = NSAttributedString(string: text, attributes:attrs)
        
        let pages = self.cutPageWith(attrString: attributedString, bounds: bounds)
        
//        let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
//
//        var characterFitRange: CFRange = CFRange()
//
//        CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), nil, CGSize(width: bounds.size.width - BookPageViewController.Constants.horizontalOffset * 2, height: bounds.size.height - BookPageViewController.Constants.verticalOffset * 2), &characterFitRange)
//
//
//        let maxPageLength = Int(characterFitRange.length)
//        let pages = text.split(by: maxPageLength)
        
        callback(pages)
    }

}

private extension BookViewModel {
    func cutPageWith(attrString: NSAttributedString, bounds: CGRect) -> [NSAttributedString]{
        let layouter = DTCoreTextLayouter.init(attributedString: attrString)
        let rect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width - BookPageViewController.Constants.horizontalOffset * 2, height: bounds.size.height - BookPageViewController.Constants.horizontalOffset * 2)
        var frame = layouter?.layoutFrame(with: rect, range: NSRange(location: 0, length: attrString.length))
        
        var pageVisibleRange = frame?.visibleStringRange()
        var rangeOffset = pageVisibleRange!.location + pageVisibleRange!.length
    
        var pages: [NSAttributedString] = []
        
        while rangeOffset <= attrString.length && rangeOffset != 0 {
            pages.append(attrString.attributedSubstring(from: pageVisibleRange!))
            
            frame = layouter?.layoutFrame(with: rect, range: NSRange(location: rangeOffset, length: attrString.length - rangeOffset))
            pageVisibleRange = frame?.visibleStringRange()
            
            if pageVisibleRange == nil {
                rangeOffset = 0
            }else {
                rangeOffset = pageVisibleRange!.location + pageVisibleRange!.length
            }
        }
        
        return pages
    }
}
