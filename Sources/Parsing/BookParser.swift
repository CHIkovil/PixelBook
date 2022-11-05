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
            guard let item = content.item else{return}
            let file = String(item.split(separator: "#")[0])
            let path = document.contentDirectory.appendingPathComponent(file).path
            let xhtml = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let text = xhtml?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            guard let text = text else{return}
            chapters.append(Chapter(title: content.label, text: text))
        }
        
        var cover: NSData?
        if let coverUrl = document.cover, let img = UIImage(named: coverUrl.path) {
            cover = img.pngData() as NSData?
        }
        
        if let title = document.title, let author = document.author, !chapters.isEmpty{
            return BookModel(cover: cover, title: title, author: author, chapter: chapters)
        }else{
            return nil
        }
    }
}
