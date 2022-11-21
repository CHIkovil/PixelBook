//
//  BookViewModel.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import Foundation
import SwiftSoup
import RxCocoa
import RxSwift
import DTCoreText
import SwiftSoup
import Dispatch


protocol BookViewModelProtocol: AnyObject {
    var newCurrentPageRelay: PublishRelay<Int> {get}
    var closeBookRelay: PublishRelay<Int> { get }
    var currentPageDriver: Driver<Int?> { get }
    
    func viewWillAppear()
    func parseToPages(callback:@escaping ([NSAttributedString]) -> Void)
}

final class BookViewModel: BookViewModelProtocol {
    let newCurrentPageRelay = PublishRelay<Int>()
    let closeBookRelay = PublishRelay<Int>()
    private lazy var currentPageRelay = PublishRelay<Int?>()
    private(set) lazy var currentPageDriver = currentPageRelay.asDriver(
        onErrorJustReturn: nil)
    
    private let model: BookModel
    
    private let router: BookRouterProtocol
    private let disposeBag = DisposeBag()
    
    init(router: BookRouterProtocol, model: BookModel) {
        self.router = router
        self.model = model
        
        closeBookRelay
            .subscribe(onNext: { [weak self] pageIndex in
                guard let self = self else {return}
                self.closeBook(pageIndex)
            })
            .disposed(by: disposeBag)
        
        newCurrentPageRelay.subscribe(onNext: { [weak self] pageIndex in
            guard let self = self else {return}
            self.updateCurrentPage(pageIndex)
        })
        .disposed(by: disposeBag)
    }
    
    func viewWillAppear(){
        getCurrentPage()
    }
    
    func parseToPages(callback:@escaping ([NSAttributedString]) -> Void) {
        BookViewModel.parseModelToPages(model) {pages in
            callback(pages)
        }
    }
}

private extension BookViewModel {
    func updateCurrentPage(_ pageIndex: Int) {
        BookRequests.updateState(book: self.model, currentPage: pageIndex)
    }
    
    func getCurrentPage() {
        UserRequests.update(UserModel(bookTitle: model.title, bookAuthor: model.author, isRead: true))
        NotificationCenter.default.post(name: .init(rawValue: AppConstants.newCurrentBookNotificationName), object: nil)
        guard let model = BookRequests.fetchOne(title: model.title, author: model.author) else{return}
        currentPageRelay.accept(model.currentPage)
    }
    
    func closeBook(_ pageIndex: Int) {
        BookRequests.updateState(book: self.model, currentPage: pageIndex)
        UserRequests.updateState(isRead: false)
        self.router.close()
    }
    
    static func parseModelToPages(_ model: BookModel, callback:@escaping ([NSAttributedString]) -> Void) {
        let config = BookConfig.value
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        let group = DispatchGroup()
        let threadLock = NSLock()
        
        let chaptersTitles = model.chapters.compactMap {$0.title}
        var chapterItems: [String: [NSAttributedString]] = [:]
        
        model.chapters.forEach { chapter in
            queue.async(group: group) {
                do {
                    let parsedChapter = try SwiftSoup.parse(chapter.xhtml)
                    let paragraphs = try parsedChapter.select("p").eachText()
                    
                    let chapterAttributedString: NSMutableAttributedString = NSMutableAttributedString()
                    
                    let variationsTitles = chapter.title.permute()
                    let titleIndex = variationsTitles.compactMap({
                        paragraphs.firstIndex(of:$0)
                    }).max()

                    let titleString = titleIndex != nil ? paragraphs[0...titleIndex!].joined(separator: "\n") + "\n" : ""
                    let textString = paragraphs[((titleIndex ?? -1) + 1)...].joined(separator: "\n")

                    let textLanguage = textString.detectedLanguage()

                    let hyphenatedTitleString = titleString.hyphenated(languageCode: textLanguage)
                    let hyphenatedTextString = textString.hyphenated(languageCode:  textLanguage)
                    
                    chapterAttributedString.append(NSAttributedString(string: hyphenatedTitleString, attributes:  config.titleAttributes))
                    
                    chapterAttributedString.append(NSAttributedString(string: hyphenatedTextString, attributes: config.textAttributes))
                    
                    
                    let pages = self.cutPageWith(attrString: chapterAttributedString, bounds: config.visibleScreenSize)
                    
                    threadLock.lock()
                    chapterItems[chapter.title] = pages
                    threadLock.unlock()
                }catch{
                    
                }
            }
        }
        
        group.wait()
        
        var pages: [NSAttributedString] = []
        
        chaptersTitles.forEach {
            guard let nextPages = chapterItems[$0] else{return}
            pages.append(contentsOf: nextPages)
        }
        
        callback(pages)
    }
    
    
    static func cutPageWith(attrString: NSAttributedString, bounds: CGRect) -> [NSAttributedString]{
        
        let layouter = DTCoreTextLayouter.init(attributedString: attrString)
        
        let rect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
        var frame = layouter?.layoutFrame(with: rect, range: NSRange(location: 0, length: attrString.length))
        
        var pageVisibleRange = frame?.visibleStringRange()
        var rangeOffset = pageVisibleRange!.location + pageVisibleRange!.length
        
        var pages: [NSAttributedString] = []
        
        while rangeOffset <= attrString.length && rangeOffset != 0 {
            let pageAttrString = attrString.attributedSubstring(from: pageVisibleRange!)
            pages.append(pageAttrString)
            pages.append(NSAttributedString(string: NSUUID().uuidString))
            
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
