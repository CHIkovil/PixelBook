//
//  BookParser.swift
//  BlackBook
//
//  Created by Nikolas on 05.11.2022.
//

import Foundation
import EPUBKit
import UIKit
import DTCoreText
import SwiftSoup
import Dispatch


class AttributedString : Codable {
    
    let attributedString : NSAttributedString
    
    init(nsAttributedString : NSAttributedString) {
        self.attributedString = nsAttributedString
    }
    
    public required init(from decoder: Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        guard let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(singleContainer.decode(Data.self)) as? NSAttributedString else {
            throw DecodingError.dataCorruptedError(in: singleContainer, debugDescription: "Data is corrupted")
        }
        self.attributedString = attributedString
    }
    
    public func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()
        try singleContainer.encode(NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false))
    }
}


final class BookParser  {
    
    static func checkContexts(contexts: Set<UIOpenURLContext>){
        if let urlContext = contexts.first {
            let url = urlContext.url
            switch url.pathExtension {
            case "epub":
                parseEpub(url: url)
            default: break
            }
        }
    }
    
    static func parseModelToPages(_ book: BookModel) -> [AttributedString] {
        let config = BookConfig.value
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        let group = DispatchGroup()
        let threadLock = NSLock()
        
        let chaptersTitles = book.chapters.compactMap {$0.title}
        var chapterItems: [String: [AttributedString]] = [:]
        
        book.chapters.forEach { chapter in
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
        
        var pages: [AttributedString] = []
        
        chaptersTitles.forEach {
            guard let nextPages = chapterItems[$0] else{return}
            pages.append(contentsOf: nextPages)
        }
        
        return pages
    }
}

private extension BookParser {
    static func didNewBook(_ model: BookModel) {
        if BookRequests.insert(model) {
            UserRequests.updateState(isRead: false)
            NotificationCenter.default.post(name: .init(rawValue: AppConstants.newBookNotificationName), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                PagesRequests.insert(model)
            }
        }else {
            NotificationCenter.default.post(name: .init(rawValue: AppConstants.repeatedBookNotificationName), object: nil)
        }
    }
    
    static func parseEpub(url: URL) {
        guard let document = EPUBDocument(url: url), let contents = document.tableOfContents.subTable else{return}
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        let group = DispatchGroup()
        let threadLock = NSLock()
        
        let chaptersTitles = contents.compactMap {$0.label}
        var chapterItems: [String: String] = [:]
        
        contents.forEach { content in
            queue.async(group: group) {
                guard let item = content.item else {return}
                
                let file = String(item.components(separatedBy: ".xhtml")[0]) + ".xhtml"
                let url = document.contentDirectory.appendingPathComponent(file)
                guard let xhtml = try? String(contentsOfFile: url.path, encoding: String.Encoding.utf8) else {return}
                
                threadLock.lock()
                chapterItems[content.label] = xhtml
                threadLock.unlock()
            }
        }
        
        group.notify(queue: .main) {
            let chapters: [Chapter] = chaptersTitles.compactMap {
                guard let xhtml = chapterItems[$0] else{return nil}
                return Chapter(title: $0, xhtml: xhtml)
            }
            
            var cover: Data?
            if let coverUrl = document.cover, let img = UIImage(named: coverUrl.path) {
                cover = img.pngData() as Data?
            }
            
            if let title = document.title, let author = document.author, !chapters.isEmpty {
                let model = BookModel(cover: cover,
                                      title: title,
                                      author: author,
                                      chapters: chapters,
                                      currentPage: 0)
                
                didNewBook(model)
            }
        }
    }
    
    
    
    static func cutPageWith(attrString: NSAttributedString, bounds: CGRect) -> [AttributedString]{
        
        let layouter = DTCoreTextLayouter.init(attributedString: attrString)
        
        let rect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
        var frame = layouter?.layoutFrame(with: rect, range: NSRange(location: 0, length: attrString.length))
        
        var pageVisibleRange = frame?.visibleStringRange()
        var rangeOffset = pageVisibleRange!.location + pageVisibleRange!.length
        
        var pages: [AttributedString] = []
        
        while rangeOffset <= attrString.length && rangeOffset != 0 {
            let pageAttrString = attrString.attributedSubstring(from: pageVisibleRange!)
            pages.append(AttributedString(nsAttributedString: pageAttrString))
            
            let uuidString = NSUUID().uuidString
            
            let emptyPageAttrString = NSMutableAttributedString(string: uuidString)
            emptyPageAttrString.addAttributes([.foregroundColor: UIColor.clear], range: (uuidString as NSString).range(of: uuidString))

            pages.append(AttributedString(nsAttributedString: emptyPageAttrString))
            
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


