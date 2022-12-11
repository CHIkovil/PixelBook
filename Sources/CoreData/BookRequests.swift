//
//  BookRequests.swift
//  BlackBook
//
//  Created by Nikolas on 06.11.2022.
//

import Foundation
import UIKit
import CoreData

final class BookRequests {
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func convertToModel(_ item: BlackBook.Book) -> BookModel{
        let chapters: [Chapter] = try! JSONDecoder().decode([Chapter].self, from: item.chapters!)
        
        let book = BookModel(cover: item.cover,
                             title: item.title!,
                             author: item.author!,
                             chapters: chapters,
                             currentPage: Int(item.currentPage))
        return book
    }
    
    static func insert(_ book: BookModel) -> Bool{
        do {
            if let _ = check(title: book.title, author: book.author){
                return false
            }
            
            let newItem = NSEntityDescription.insertNewObject(forEntityName: AppConstants.bookEntityName, into: context) as! BlackBook.Book
            
            let chaptersData = try? JSONEncoder().encode(book.chapters)
           
                
            newItem.cover = book.cover
            newItem.title = book.title
            newItem.author = book.author
            newItem.chapters = chaptersData
            newItem.currentPage = Int32(book.currentPage)
            
            try context.save()
            
            return true
        } catch {
            fatalError()
        }
    }
    
    static func updateState(book: BookModel, currentPage: Int) {
        do {
            guard let item = check(title: book.title, author: book.author) else {return}
            item.setValue(currentPage, forKey: "currentPage")
            try context.save()
        }catch {
            fatalError()
        }
    }
    
    static func fetchOne(title: String, author: String) -> BookModel? {
        if let item = check(title: title, author: author) {
            let model = convertToModel(item)
            return model
        }else {
            return nil
        }
     }

    static func delete(_ book: BookModel) {
        do {
            guard let item = check(title: book.title, author: book.author) else{return}
            context.delete(item)
            
            try context.save()
        } catch {
            fatalError()
        }
    }
    
    private static func check(title: String, author: String) -> BlackBook.Book?{
        do {
            let fetchRequest = NSFetchRequest<BlackBook.Book>(entityName: AppConstants.bookEntityName)
            
            let predicateTitle = NSPredicate(format: "title = %@", title)
            let predicateAuthor = NSPredicate(format: "author = %@", author)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateTitle, predicateAuthor])
            
            fetchRequest.predicate = predicate
            
            let results = try context.fetch(fetchRequest)
            
            try context.save()
            
            return results.first
        } catch {
            fatalError()
        }
    }
}

