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

final class BookParser  {
    enum BookConfig {
        struct Config{
            let screenSize: CGRect
            let stringAttributes: [NSAttributedString.Key : Any]
        }
        
        case epub
        
        var value: Config {
            switch self {
            case .epub:
                var screenSize: CGRect = UIScreen.main.bounds
                screenSize.size.width -= PageConstants.widthOffset * 2 + 20
                screenSize.size.height -= PageConstants.heightOffset * 2 + 200
                
                let universalTextSpacing: CGFloat = 10
                let textFont: UIFont = UIFont(name: "Arial", size: 20)!
                
                let style = NSMutableParagraphStyle()
                style.lineSpacing = universalTextSpacing
                style.paragraphSpacing = universalTextSpacing
                style.hyphenationFactor = 1.0
                style.lineBreakMode = .byWordWrapping
                style.alignment = .natural
                
                let attrs: [NSAttributedString.Key : Any] = [.font: textFont as Any,
                                                                 .foregroundColor:
                                                                    AppColor.readText,
                                                                 .paragraphStyle: style]
                
                return Config(screenSize: screenSize,
                              stringAttributes: attrs)
            }
        }
    }
    
    
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
    
    private static func parseEpub(url: URL) {
        guard let document = EPUBDocument(url: url), let contents = document.tableOfContents.subTable else{return}
        
        let group = DispatchGroup()
        let config = BookConfig.epub.value
        let bookChapters = contents.compactMap {$0.label}
        var chapterPages: [String:[AttributedString]] = [:]
        
        contents.forEach { content in
            group.enter()
            do {
                defer {group.leave()}
            
                guard let item = content.item else {return}
                
                let file = String(item.components(separatedBy: ".xhtml")[0]) + ".xhtml"
                let url = document.contentDirectory.appendingPathComponent(file)
                let xhtml = try String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
                
                let parsedChapter = try SwiftSoup.parse(xhtml)
                let text = try parsedChapter.select("p").eachText().joined(separator: "\n")
                let chapterAttributedString = NSAttributedString(string: text, attributes: config.stringAttributes)
                
                let pages = self.cutPageWith(attrString: chapterAttributedString, bounds: config.screenSize)
                
                chapterPages[content.label] = pages
                
            } catch {
            }
        }
        
        group.notify(queue: .main) {
            var bookPages: [AttributedString] = []
            
            bookChapters.forEach {
                guard let pages = chapterPages[$0] else{return}
                bookPages += pages
            }
            
            var cover: Data?
            if let coverUrl = document.cover, let img = UIImage(named: coverUrl.path) {
                cover = img.pngData() as Data?
            }
            
            if let title = document.title, let author = document.author, !bookPages.isEmpty{
                let model = BookModel(cover: cover, title: title, author: author, pages: bookPages, currentPage: 0)
                BookRequests.insert(model)
                UserRequests.updateState(isRead: false)
                NotificationCenter.default.post(name: .init(rawValue: AppConstants.newBookNotificationName), object: nil)
            }
        }

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
            
            pages += [AttributedString(nsAttributedString: pageAttrString), AttributedString(nsAttributedString: emptyPageAttrString)]
            
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


