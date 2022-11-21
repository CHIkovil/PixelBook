//
//  BookParser.swift
//  BlackBook
//
//  Created by Nikolas on 05.11.2022.
//

import Foundation
import EPUBKit
import UIKit
import Dispatch

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
    
    private static func parseEpub(url: URL) {
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
                
                BookRequests.insert(model)
                UserRequests.updateState(isRead: false)
                NotificationCenter.default.post(name: .init(rawValue: AppConstants.newBookNotificationName), object: nil)
            }
        }

    }
}


