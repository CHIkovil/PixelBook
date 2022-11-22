//
//  UserRequests.swift
//  BlackBook
//
//  Created by Nikolas on 15.11.2022.
//

import Foundation
import UIKit
import CoreData

final class UserRequests {
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func update(_ model: UserModel) {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AppConstants.userEntityName)
            if let results = try context.fetch(fetchRequest) as? [NSManagedObject], let item = results.first {
                item.setValue(model.bookTitle, forKey: "bookTitle")
                item.setValue(model.bookAuthor, forKey: "bookAuthor")
                item.setValue(model.isRead, forKey: "isRead")
            }else{
                insert(model)
            }
            try context.save()
        }catch {
            fatalError()
        }
    }
    
    static func updateState(isRead: Bool) {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AppConstants.userEntityName)
            guard let results = try context.fetch(fetchRequest) as? [NSManagedObject], let item = results.first else{return}
            item.setValue(isRead, forKey: "isRead")
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
                let model = UserModel(bookTitle: item.bookTitle!, bookAuthor: item.bookAuthor!, isRead: item.isRead)
                result = model
            }
            
            try context.save()
        } catch {
        }
        
        return result
    }
    
    private static func insert(_ model: UserModel) {
        do {
            let newItem = NSEntityDescription.insertNewObject(forEntityName: AppConstants.userEntityName, into: context) as! BlackBook.User
            
            newItem.bookTitle = model.bookTitle
            newItem.bookAuthor = model.bookAuthor
            newItem.isRead = model.isRead
            
            try context.save()
        } catch {
            fatalError()
        }
    }
}

