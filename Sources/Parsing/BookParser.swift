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

final class BookParser  {
    static func checkContexts(contexts: Set<UIOpenURLContext>){
        if let urlContext = contexts.first {
            let url = urlContext.url
            switch url.pathExtension {
            case "epub":
                guard let model = parseEpub(url: url) else {return}
                BookRequests.insert(model)
                UserRequests.updateState(isRead: false)
                NotificationCenter.default.post(name: .init(rawValue: AppConstants.newBookNotificationName), object: nil)
            default: break
            }
        }
    }
    
    private static func parseEpub(url: URL) -> BookModel? {
        guard let document = EPUBDocument(url: url), let contents = document.tableOfContents.subTable else{return nil}
        
        var screenSize: CGRect = UIScreen.main.bounds
        screenSize.size.width -= PageConstants.widthOffset * 2 + 20
        screenSize.size.height -= PageConstants.heightOffset * 2 + 150
        
        let attrs = setupAttrs()
        var chapterPageIndex: Int = 0
        var bookSpine: [String: Int] = [:]
        var pages: [AttributedString] = []
        
        contents.forEach { content in
            do {
                guard let item = content.item else{return}
                let file = String(item.components(separatedBy: ".xhtml")[0]) + ".xhtml"
                let url = document.contentDirectory.appendingPathComponent(file)
                
                let xhtml = try String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
                
                let parsedChapter = try? SwiftSoup.parse(xhtml)
                let paragraphs = try? parsedChapter?.select("p").eachText()
                guard let paragraphs = paragraphs else{return}
                
                let attributedString: NSMutableAttributedString = NSMutableAttributedString()
                
                if let titleIndex = paragraphs.firstIndex(of: content.label){
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
                
                let nextPages = self.cutPageWith(attrString: attributedString, bounds: screenSize)
                bookSpine[content.label] = chapterPageIndex
                pages += nextPages
                chapterPageIndex = nextPages.count + 1
            }catch {
                return
            }
        }
        
        var cover: Data?
        if let coverUrl = document.cover, let img = UIImage(named: coverUrl.path) {
            cover = img.pngData() as Data?
        }
        
        if let title = document.title, let author = document.author, !bookSpine.isEmpty, !pages.isEmpty{
            return BookModel(cover: cover, title: title, author: author, spine: bookSpine, pages: pages, currentPage: 0)
        }else{
            return nil
        }
    }
    
    private static func setupAttrs() -> (title: [NSAttributedString.Key : Any], text: [NSAttributedString.Key : Any]) {
        let universalTextSpacing: CGFloat = 7
        let titleFont:UIFont = UIFont(name: "Arial", size: 25)!
        let textFont: UIFont = UIFont(name: "Arial", size: 20)!
        
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.lineSpacing = universalTextSpacing
        titleStyle.paragraphSpacing = universalTextSpacing + 5
        titleStyle.alignment = .center
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.lineSpacing = universalTextSpacing
        textStyle.paragraphSpacing = universalTextSpacing
        textStyle.hyphenationFactor = 1.0
        textStyle.lineBreakMode = .byWordWrapping
        textStyle.alignment = .justified
        
        let titleAttrs: [NSAttributedString.Key : Any] = [.font: titleFont as Any,
                                                          .foregroundColor:
                                                            AppColor.readText,
                                                          .paragraphStyle: titleStyle]
        
        let textAttrs: [NSAttributedString.Key : Any] = [.font: textFont as Any,
                                                         .foregroundColor:
                                                            AppColor.readText,
                                                         .paragraphStyle: textStyle]
        return (title: titleAttrs, text: textAttrs)
    }
    
    private static func cutPageWith(attrString: NSAttributedString, bounds: CGRect) -> [AttributedString]{
        
        let layouter = DTCoreTextLayouter.init(attributedString: attrString)
        let rect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
        var frame = layouter?.layoutFrame(with: rect, range: NSRange(location: 0, length: attrString.length))
        
        var pageVisibleRange = frame?.visibleStringRange()
        var rangeOffset = pageVisibleRange!.location + pageVisibleRange!.length
    
        var pages: [AttributedString] = []
        
        while rangeOffset <= attrString.length && rangeOffset != 0 {
            let pageAttrString = attrString.attributedSubstring(from: pageVisibleRange!)
            let emptyPageAttrString = NSAttributedString(string: NSUUID().uuidString)
            
            pages.append(AttributedString(nsAttributedString: pageAttrString))
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


