//
//  CoreDataManager.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "DraftModels")
        persistentContainer.loadPersistentStores { store, error in
            if let error = error {
                print("Failed to load Core Data stack: \(error)")
            }
            
            if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                print("📂 Core Data DB path: \(url.path)")
            }
            
            if let storeURL = store.url {
                print("📂 SQLite DB file: \(storeURL.path)")
            }

        }
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}

