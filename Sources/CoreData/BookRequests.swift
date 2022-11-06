//
//  BookRequests.swift
//  BlackBook
//
//  Created by Nikolas on 06.11.2022.
//

import Foundation
import UIKit
import CoreData

class BookRequests {
    enum Constants {
        static let entityName: String = "Book"
    }
    
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    static func insert(_ book: BookModel) {
        do {
            if let _ = check(book) {
                return
            }
            
            let newItem = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: context) as! BlackBook.Book
            
            let chaptersData = try? JSONEncoder().encode(book.chapters)
                
            newItem.cover = book.cover
            newItem.title = book.title
            newItem.author = book.author
            newItem.chapters = chaptersData
            
            try context.save()
        } catch {
            fatalError()
        }
    }

    static func fetch() -> [BookModel]? {
        var result: [BookModel]?
        
        do {
            let fetchRequest = NSFetchRequest<BlackBook.Book>(entityName: Constants.entityName)
            let results = try context.fetch(fetchRequest)
            
            var books: [BookModel] = []
            results.forEach { item in
                let chapters: [Chapter] = try! JSONDecoder().decode([Chapter].self, from: item.chapters!)
                let book = BookModel(cover: item.cover,
                                     title: item.title!,
                                     author: item.author!,
                                     chapters: chapters)
                books.append(book)
            }
            
            result = books
            
            try context.save()
        } catch {
        }
        return result
    }

    static func delete(_ book: BookModel) {
        do {
            guard let item = check(book) else{return}
            context.delete(item)
            
            try context.save()
        } catch {
            fatalError()
        }
    }
    
    private static func check(_ book: BookModel) -> BlackBook.Book?{
        do {
            let fetchRequest = NSFetchRequest<BlackBook.Book>(entityName: Constants.entityName)
            let results = try context.fetch(fetchRequest)
            
            let filteredResult = results.filter {
                var hasher = Hasher()
                hasher.combine(($0.title! + $0.author!).replacingOccurrences(of: " ", with: "").lowercased())
                
                return hasher.finalize() == book.hashValue
            }
            
            try context.save()

            if let item = filteredResult.first{
                return item
            }
            else{
                return nil
            }
        } catch {
            fatalError()
        }
    }
}

