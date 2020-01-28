//
//  NSManagedObjectContext+Async.swift
//  StorageKit
//
//  Created by Victor Shabanov on 26/07/2019.
//  Copyright © 2019 Victor Shabanov. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
    
    // MARK: - Async operations
    
    func performAsync(_ closure: @escaping (_ privateContext: NSManagedObjectContext) -> Void) {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        context.perform {
            context.parent = self
            
            closure(context)
        }
    }
    
    func performAsync(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>,
                      _ closure: @escaping (_ result: [Any]?, _ error: Error?) -> Void) {
        let resultType = fetchRequest.resultType
        
        performAsync { privateContext in
            var result: [Any]? = nil
            var error: Error? = nil
            
            do {
                result = try privateContext.fetch(fetchRequest)
                
                self.perform {
                    if resultType == .managedObjectResultType, let resultObjects = result as? [NSManagedObject], resultObjects.count > 0 {
                        var managedObjects: [NSManagedObject] = []
                        
                        if let objectIds = (resultObjects as NSArray).value(forKey: "objectID") as? [NSManagedObjectID] {
                            managedObjects = objectIds.map {
                                self.object(with: $0)
                            }
                        }
                        
                        closure(managedObjects, error)
                    }
                    else {
                        closure(result, error)
                    }
                }
                return
            }
            catch let fetchError {
                error = fetchError
            }
            
            self.perform {
                closure(result, error)
            }
        }
    }
    
    func performAsync<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>,
                                          _ closure: @escaping (_ result: [T]?, _ error: Error?) -> Void) {
        guard fetchRequest.resultType == .managedObjectResultType else {
            closure(nil, nil)
            return
        }
        
        performAsync { privateContext in
            var result: [T]? = nil
            var error: Error? = nil
            
            do {
                result = try privateContext.fetch(fetchRequest)
                
                self.perform {
                    if let resultObjects = result, resultObjects.count > 0 {
                        var managedObjects: [T] = []
                        
                        if let objectIds = (resultObjects as NSArray).value(forKey: "objectID") as? [NSManagedObjectID] {
                            managedObjects = objectIds.compactMap {
                                self.object(with: $0) as? T
                            }
                        }
                        
                        closure(managedObjects, error)
                    }
                    else {
                        closure(result, error)
                    }
                }
                return
            }
            catch let fetchError {
                error = fetchError
            }
            
            self.perform {
                closure(result, error)
            }
        }
    }
    
    // MARK: - Save operations
    
    func saveToStoreAsync(_ completion: @escaping (_ error: Error?) -> Void) {
        guard hasChanges else {
            completion(nil)
            return
        }
        
        performAsync { context in
            var savingError: Error?
            
            do {
                try context.saveToStore()
            }
            catch {
                savingError = error
            }
            
            self.perform {
                completion(savingError)
            }
        }
    }
    
    func saveToStore() throws {
        var contextToSave: NSManagedObjectContext? = self
        var localError: Error?
        
        while contextToSave != nil {
            contextToSave?.performAndWait {
                do {
                    if let inserted = contextToSave?.insertedObjects {
                        try contextToSave?.obtainPermanentIDs(for: Array(inserted))
                        try contextToSave?.save()
                    }
                }
                catch {
                    localError = error
                }
            }
            
            if let error = localError {
                throw error
            }
            
            if let parent = contextToSave?.parent, let _ = contextToSave?.persistentStoreCoordinator {
                contextToSave = parent
            }
            else {
                break
            }
        }
    }
}
