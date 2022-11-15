//
//  BookParser.swift
//  BlackBook
//
//  Created by Nikolas on 05.11.2022.
//

import Foundation
import EPUBKit
import UIKit


final class BookParser  {
    static func parseFile(url: URL) -> BookModel? {
        switch url.pathExtension {
        case "epub":
            return parseEpub(url: url)
        default:
            return nil
        }
    }
    
    private static func parseEpub(url: URL) -> BookModel? {
        
        guard let document = EPUBDocument(url: url), let contents = document.tableOfContents.subTable else{return nil}
        
        var chapters: [Chapter] = []
        contents.forEach { content in
            do {
                guard let item = content.item else{return}
                let file = String(item.components(separatedBy: ".xhtml")[0]) + ".xhtml"
                let url = document.contentDirectory.appendingPathComponent(file)
                
                let xhtml = try String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
                chapters.append(Chapter(title: content.label, xhtml: xhtml))
            }catch {
                return
            }
        }
        
        var cover: Data?
        if let coverUrl = document.cover, let img = UIImage(named: coverUrl.path) {
            cover = img.pngData() as Data?
        }
        
        if let title = document.title, let author = document.author, !chapters.isEmpty{
            return BookModel(cover: cover, title: title, author: author, chapters: chapters, currentPage: 0)
        }else{
            return nil
        }
    }
}

