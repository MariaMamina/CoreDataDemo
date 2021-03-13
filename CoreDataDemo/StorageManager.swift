//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Maria Mamina on 13.03.2021.
//

import Foundation
import  CoreData

class StorageManager {
    static let shared = StorageManager()
    
     private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
    
    

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private init() {}
    
}
