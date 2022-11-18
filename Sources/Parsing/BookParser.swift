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
            let titleAttributes: [NSAttributedString.Key : Any]
            let textAttributes: [NSAttributedString.Key : Any]
        }
        
        case epub
        
        var value: Config {
            switch self {
            case .epub:
                var screenSize: CGRect = UIScreen.main.bounds
                screenSize.size.width -= PageConstants.widthOffset * 2 + 20
                screenSize.size.height -= PageConstants.heightOffset * 2 + 200
                
                let universalTextSpacing: CGFloat = 10
                let titleFont: UIFont = UIFont(name: "Arial", size: 25)!
                let textFont: UIFont = UIFont(name: "Arial", size: 20)!
                
                let titleStyle = NSMutableParagraphStyle()
                titleStyle.lineSpacing = universalTextSpacing
                titleStyle.paragraphSpacing = universalTextSpacing * 2
                titleStyle.alignment = .center
                
                let textStyle = NSMutableParagraphStyle()
                textStyle.lineSpacing = universalTextSpacing
                textStyle.paragraphSpacing = universalTextSpacing
                textStyle.hyphenationFactor = 1.0
                textStyle.firstLineHeadIndent = 20
                textStyle.lineBreakMode = .byCharWrapping
                textStyle.alignment = .justified
                
                let titleAttrs: [NSAttributedString.Key : Any] = [.font: titleFont as Any,
                                                                 .foregroundColor:
                                                                    AppColor.readText,
                                                                 .paragraphStyle: titleStyle]
                
                let textAttrs: [NSAttributedString.Key : Any] = [.font: textFont as Any,
                                                                 .foregroundColor:
                                                                    AppColor.readText,
                                                                 .paragraphStyle: textStyle]
                
       
                
                return Config(screenSize: screenSize,
                              titleAttributes: titleAttrs,
                              textAttributes: textAttrs)
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
                var paragraphs = try parsedChapter.select("p").eachText()
                
                let chapterAttributedString: NSMutableAttributedString = NSMutableAttributedString()
                
                guard let titleIndex = paragraphs.firstIndex(of: content.label) else{return}
                
                chapterAttributedString.append(NSAttributedString(string: paragraphs[0...titleIndex].joined(separator: "\n") + "\n", attributes:  config.titleAttributes))
                chapterAttributedString.append(NSAttributedString(string: paragraphs[(titleIndex + 1)...].joined(separator: "\n"), attributes: config.textAttributes))
                
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
            pages.append(AttributedString(nsAttributedString: pageAttrString))
            
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


