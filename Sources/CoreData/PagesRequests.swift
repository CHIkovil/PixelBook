//
//  PagesRequests.swift
//  BlackBook
//
//  Created by Nikolas on 22.11.2022.
//

import Foundation
import UIKit
import CoreData

final class PagesRequests {
    
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    static func insert(_ book: BookModel){
        do {
            let newItem = NSEntityDescription.insertNewObject(forEntityName: AppConstants.pagesEntityName, into: context) as! BlackBook.Pages
            
            let pages = BookParser.parseModelToPages(book)
            
            let pagesData = try JSONEncoder().encode(pages)
           
            newItem.title = book.title
            newItem.author = book.author
            newItem.data = pagesData
            
            try context.save()
        } catch {
            fatalError()
        }
    }
    
    static func fetchOne(title: String, author: String) -> [AttributedString]? {
         var result: [AttributedString]?
         
         do {
             let fetchRequest = NSFetchRequest<BlackBook.Pages>(entityName: AppConstants.pagesEntityName)
             
             let predicateTitle = NSPredicate(format: "title = %@", title)
             let predicateAuthor = NSPredicate(format: "author = %@", author)
             let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateTitle, predicateAuthor])
             
             fetchRequest.predicate = predicate
             
             let results = try context.fetch(fetchRequest)
             
             try context.save()
             
             if let item = results.first, let pages: [AttributedString] = try? JSONDecoder().decode([AttributedString].self, from: item.data!) {
                 return pages
             }else{
                 return nil
             }
             
         } catch {
         }
         
         return result
     }
}