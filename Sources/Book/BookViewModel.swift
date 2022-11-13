//
//  BookViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import SwiftSoup
import DTCoreText
import RxCocoa
import RxSwift


protocol BookViewModelProtocol: AnyObject {
    var closeBookRelay: PublishRelay<Void> { get }
    func parseModelToPages(bounds: CGRect, attrs: (title: [NSAttributedString.Key : Any], text: [NSAttributedString.Key : Any]), callback: @escaping(Pages) -> Void)
}

final class BookViewModel: BookViewModelProtocol {
    let closeBookRelay = PublishRelay<Void>()
    
    private let model: BookModel
    
    private let router: BookRouterProtocol
    private let disposeBag = DisposeBag()
    
    init(router: BookRouterProtocol, model: BookModel) {
        self.router = router
        self.model = model
        
        closeBookRelay
            .subscribe(onNext: { [weak self] model in
                guard let self = self else {return}
                self.closeBook()
            })
            .disposed(by: disposeBag)
    }
    
    func parseModelToPages(bounds: CGRect, attrs: (title: [NSAttributedString.Key : Any], text: [NSAttributedString.Key : Any]), callback: @escaping(Pages) -> Void){
        
        var chapterPageIndex: Int = 0
        var spine: [String: Int] = [:]
        var pagesItems: [NSAttributedString] = []
        
        model.chapters.forEach {chapter in
            let parsedChapter = try? SwiftSoup.parse(chapter.xhtml)
            let paragraphs = try? parsedChapter?.select("p").eachText()
            guard let paragraphs = paragraphs else{return}
            
            let attributedString: NSMutableAttributedString = NSMutableAttributedString()
            
            if let titleIndex = paragraphs.firstIndex(of: chapter.title){
                paragraphs.enumerated().forEach {index, p in
                    if index <= titleIndex {
                        attributedString.append(NSAttributedString(string: p + "\n", attributes: attrs.title))
                    }else{
                        attributedString.append(NSAttributedString(string: "\t" + p + "\n", attributes: attrs.text))
                    }
                }
            }else {
                paragraphs.forEach { p in
                    attributedString.append(NSAttributedString(string: "\t" + p + "\n", attributes: attrs.text))
                }
            }
            
            let nextPagesItems = self.cutPageWith(attrString: attributedString, bounds: bounds)
            spine[chapter.title] = chapterPageIndex
            chapterPageIndex = nextPagesItems.count + 1
            pagesItems += nextPagesItems
        }
        
        let pages = Pages(spine: spine, items: pagesItems)
        
        callback(pages)
    }
}

private extension BookViewModel {
    func closeBook() {
        self.router.close()
    }
    func cutPageWith(attrString: NSAttributedString, bounds: CGRect) -> [NSAttributedString]{
        let layouter = DTCoreTextLayouter.init(attributedString: attrString)
        let rect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
        var frame = layouter?.layoutFrame(with: rect, range: NSRange(location: 0, length: attrString.length))
        
        var pageVisibleRange = frame?.visibleStringRange()
        var rangeOffset = pageVisibleRange!.location + pageVisibleRange!.length
    
        var pages: [NSAttributedString] = []
        
        while rangeOffset <= attrString.length && rangeOffset != 0 {
            let emptyPage = NSAttributedString(string: "\(pages.count)")
            pages.append(attrString.attributedSubstring(from: pageVisibleRange!))
            pages.append(emptyPage)
            
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
