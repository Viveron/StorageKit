//
//  CoreDataStorage.swift
//  StorageKit
//
//  Created by Victor Shabanov on 26/07/2019.
//  Copyright © 2019 Victor Shabanov. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataStorage {
    
    public let container: NSPersistentContainer
    
    public var mainManagedObjectContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    public convenience init?(name: String, bundle: Bundle = .main, blank: Bool = false, protection: FileProtectionType = .none) {
        guard let model = NSManagedObjectModel(name: name, bundle: bundle) else {
            return nil
        }

        self.init(name: name, managedObjectModel: model, blank: blank, protection: protection)
    }

    public init?(name: String, managedObjectModel: NSManagedObjectModel, autoMigrate: Bool = false, blank: Bool = false, protection: FileProtectionType = .none) {
        guard let description = NSPersistentStoreDescription.createSQLiteStore(name: name, blank: blank) else {
            return nil
        }

        if autoMigrate {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        description.shouldAddStoreAsynchronously = true
        description.setOption(protection as NSObject, forKey: NSPersistentStoreFileProtectionKey)

        self.container = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)
        self.container.persistentStoreDescriptions = [description]
    }
    
    public func load(_ completion: @escaping (Error?) -> Void) {
        container.loadPersistentStores { _, error in
            completion(error)
        }
    }
    
    public func clear(_ completion: @escaping (Error?) -> Void) {
        let names = container.managedObjectModel.entities.compactMap { $0.name }
        
        mainManagedObjectContext.performAsync { context in
            names.forEach { name in
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                _ = try? context.execute(batchDeleteRequest)
            }
            
            var savingError: Error?
            do {
                try context.saveToStore()
            }
            catch {
                savingError = error
            }
            
            self.mainManagedObjectContext.perform {
                completion(savingError)
            }
        }
    }
}
