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
        let spine: [String:Int] = try! JSONDecoder().decode([String:Int].self, from: item.spine!)
        let pages: [AttributedString] = try! JSONDecoder().decode([AttributedString].self, from: item.pages!)
        
        let book = BookModel(cover: item.cover,
                             title: item.title!,
                             author: item.author!,
                             spine: spine,
                             pages: pages,
                             currentPage: Int(item.currentPage))
        return book
    }
    
    static func insert(_ book: BookModel) {
        do {
            if let _ = check(book) {
                return
            }
            
            let newItem = NSEntityDescription.insertNewObject(forEntityName: AppConstants.bookEntityName, into: context) as! BlackBook.Book
            
            let spineData = try? JSONEncoder().encode(book.spine)
            let pagesData = try? JSONEncoder().encode(book.pages)
           
                
            newItem.cover = book.cover
            newItem.title = book.title
            newItem.author = book.author
            newItem.spine = spineData
            newItem.pages = pagesData
            newItem.currentPage = Int32(book.currentPage)
            
            try context.save()
        } catch {
            fatalError()
        }
    }
    
    static func updateState(model: BookModel, currentPage: Int) {
        do {
            guard let item = check(model) else {return}
            item.setValue(currentPage, forKey: "currentPage")
            try context.save()
        }catch {
            fatalError()
        }
    }
    
    static func fetchOne(title: String, author: String) -> BookModel? {
         var result: BookModel?
         
         do {
             let fetchRequest = NSFetchRequest<BlackBook.Book>(entityName: AppConstants.bookEntityName)
             
             let predicateTitle = NSPredicate(format: "title = %@", title)
             let predicateAuthor = NSPredicate(format: "author = %@", author)
             let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateTitle, predicateAuthor])
             
             fetchRequest.predicate = predicate
             
             let results = try context.fetch(fetchRequest)
             
             if let item = results.first {
                 let model = convertToModel(item)
                 result = model
             }
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
            
            if let item = results.first {
                return item
            }else{
                return nil
            }
        } catch {
            fatalError()
        }
    }
}

