//
//  UserRequests.swift
//  BlackBook
//
//  Created by Nikolas on 15.11.2022.
//

import Foundation
import UIKit
import CoreData

class UserRequests {
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func update(bookTitle: String, bookAuthor: String, pageIndex: Int) {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AppConstants.userEntityName)
            if let results = try context.fetch(fetchRequest) as? [NSManagedObject], let item = results.first {
                    item.setValue(bookTitle, forKey: "bookTitle")
                    item.setValue(bookAuthor, forKey: "bookAuthor")
                    item.setValue(pageIndex, forKey: "pageIndex")
            }else{
                insert(bookTitle: bookTitle, bookAuthor: bookAuthor, pageIndex: pageIndex)
            }
            try context.save()
        }catch {
            fatalError()
        }
    }
    
    static func fetch() -> UserModel? {
         var result: UserModel?
         
         do {
             let fetchRequest = NSFetchRequest<BlackBook.User>(entityName: AppConstants.userEntityName)
             let results = try context.fetch(fetchRequest)
             
             if let item = results.first {
                 let model = UserModel(bookTitle: item.bookTitle!, bookAuthor: item.bookAuthor!, pageIndex: Int(item.pageIndex))
                 result = model
             }
             
             try context.save()
         } catch {
         }
         
         return result
     }
    
    private static func insert(bookTitle: String, bookAuthor: String, pageIndex: Int) {
        do {
            let newItem = NSEntityDescription.insertNewObject(forEntityName: AppConstants.userEntityName, into: context) as! BlackBook.User
            
    
            newItem.bookTitle = bookTitle
            newItem.bookAuthor = bookAuthor
            newItem.pageIndex = Double(pageIndex)
            
            try context.save()
        } catch {
            fatalError()
        }
    }
}

