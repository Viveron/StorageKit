//
//  NSManagedObject+StorageManagedObject.swift
//  StorageKit
//
//  Created by Victor Shabanov on 26/07/2019.
//  Copyright © 2019 Victor Shabanov. All rights reserved.
//

import Foundation
import CoreData

public extension StorageManagedObject where Self: NSManagedObject {
    
    typealias ManagedObject = Self
    typealias FetchRequest = NSFetchRequest<Self>
    
    // MARK: - Entity
    
    static var entityName: String {
        return entity().name ?? String(describing: ManagedObject.self)
    }
    
    // MARK: - ManagedObject
    
    static func create(in context: NSManagedObjectContext) -> ManagedObject {
        return ManagedObject(context: context)
    }
    
    func delete(in context: NSManagedObjectContext) {
        context.delete(self)
    }
    
    // MARK: - FetchRequest
    
    static func fetchRequest(_ closure: ((FetchRequest) -> Void)? = nil) -> FetchRequest {
        let request = FetchRequest(entityName: entityName)
        closure?(request)
        return request
    }
    
    static func fetchRequest(_ predicate: NSPredicate? = nil,
                             _ sortDescriptors: [NSSortDescriptor]? = nil) -> FetchRequest {
        return fetchRequest { (request) in
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
        }
    }
    
    // MARK: - Sync operations
    
    static func exist(in context: NSManagedObjectContext,
                      _ predicate: NSPredicate? = nil) throws -> Bool {
        return try exist(in: context, fetchRequest { (request) in
            request.predicate = predicate
            request.fetchLimit = 1
        })
    }
    
    static func exist(in context: NSManagedObjectContext,
                      _ fetchRequest: FetchRequest) throws -> Bool {
        let count = try context.count(for: fetchRequest)
        return count > 0
    }
    
    static func count(in context: NSManagedObjectContext,
                      _ predicate: NSPredicate? = nil) throws -> Int {
        return try count(in: context, fetchRequest(predicate))
    }
    
    static func count(in context: NSManagedObjectContext,
                      _ fetchRequest: FetchRequest) throws -> Int {
        return try context.count(for: fetchRequest)
    }
    
    static func fetch(in context: NSManagedObjectContext,
                      _ predicate: NSPredicate? = nil,
                      _ sortDescriptors: [NSSortDescriptor]? = nil) throws -> [ManagedObject] {
        return try fetch(in: context, fetchRequest(predicate, sortDescriptors))
    }
    
    static func fetch(in context: NSManagedObjectContext,
                      _ fetchRequest: FetchRequest) throws -> [ManagedObject] {
        return try context.fetch(fetchRequest)
    }
    
    static func fetchFirst(in context: NSManagedObjectContext,
                           _ predicate: NSPredicate) throws -> ManagedObject? {
        let request = fetchRequest { (request) in
            request.predicate = predicate
            request.fetchLimit = 1
        }
        
        return try fetch(in: context, request).first
    }
    
    static func fetchOrCreate(in context: NSManagedObjectContext,
                              _ predicate: NSPredicate? = nil) -> ManagedObject {
        var created: Bool = false
        return fetchOrCreate(in: context, &created, predicate)
    }
    
    static func fetchOrCreate(in context: NSManagedObjectContext,
                              _ created: inout Bool,
                              _ predicate: NSPredicate? = nil) -> ManagedObject {
        let request = fetchRequest { (request) in
            request.predicate = predicate
            request.fetchLimit = 1
        }
        
        if let fetched = try? fetch(in: context, request), let managedObject = fetched.first {
            created = false
            return managedObject
        }
        
        created = true
        return create(in: context)
    }
    
    // MARK: - Async operations
    
    static func fetchAsync(in context: NSManagedObjectContext,
                           _ predicate: NSPredicate? = nil,
                           _ sortDescriptors: [NSSortDescriptor]? = nil,
                           _ closure: @escaping (_ result: [ManagedObject]?, _ error: Error?) -> Void) {
        fetchAsync(in: context, fetchRequest(predicate, sortDescriptors), closure)
    }
    
    static func fetchAsync(in context: NSManagedObjectContext,
                           _ fetchRequest: FetchRequest,
                           _ closure: @escaping (_ result: [ManagedObject]?, _ error: Error?) -> Void) {
        context.performAsync(fetchRequest) { [closure] result, error in
            closure(result, error)
        }
    }
    
    static func fetchOrCreateAsync(in context: NSManagedObjectContext,
                                   _ predicate: NSPredicate? = nil,
                                   _ closure: @escaping (_ result: ManagedObject, _ created: Bool, _ error: Error?) -> Void) {
        let request = fetchRequest { (request) in
            request.predicate = predicate
            request.fetchLimit = 1
        }
        
        fetchAsync(in: context, request) { [closure] result, error in
            if let managedObject = result?.first {
                closure(managedObject, false, error)
            } else {
                closure(create(in: context), true, error)
            }
        }
    }
}
