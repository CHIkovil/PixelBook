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
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func convertToModel(_ item: BlackBook.Book) -> BookModel{
        let chapters: [Chapter] = try! JSONDecoder().decode([Chapter].self, from: item.chapters!)
        let book = BookModel(cover: item.cover,
                             title: item.title!,
                             author: item.author!,
                             chapters: chapters)
        return book
    }
    
    static func insert(_ book: BookModel) {
        do {
            if let _ = check(book) {
                return
            }
            
            let newItem = NSEntityDescription.insertNewObject(forEntityName: AppConstants.bookEntityName, into: context) as! BlackBook.Book
            
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
            let fetchRequest = NSFetchRequest<BlackBook.Book>(entityName: AppConstants.bookEntityName)
            let results = try context.fetch(fetchRequest)
            
            var books: [BookModel] = []
            results.forEach { item in
                let book = BookRequests.convertToModel(item)
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
            let fetchRequest = NSFetchRequest<BlackBook.Book>(entityName: AppConstants.bookEntityName)
            let predicateTitle = NSPredicate(format: "title = %@", book.title)
            let predicateAuthor = NSPredicate(format: "author = %@", book.author)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateTitle, predicateAuthor])
            fetchRequest.predicate = predicate
            
            let results = try context.fetch(fetchRequest)
            try context.save()
            
            if !results.isEmpty {
                return results.first
            }else{
                return nil
            }
        } catch {
            fatalError()
        }
    }
}

