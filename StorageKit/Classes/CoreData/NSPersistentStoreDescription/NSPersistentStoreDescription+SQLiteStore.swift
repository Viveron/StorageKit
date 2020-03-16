//
//  NSPersistentStoreDescription+SQLiteStore.swift
//  StorageKit
//
//  Created by Victor Shabanov on 26/07/2019.
//  Copyright © 2019 Victor Shabanov. All rights reserved.
//

import Foundation
import CoreData

public extension NSPersistentStoreDescription {
    
    static func createSQLiteStore(name: String, blank: Bool = false) -> NSPersistentStoreDescription? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        guard let storeURL = documentDirectory?.appendingPathComponent("\(name).sqlite") else {
            return nil
        }
        
        if blank {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        
        return description
    }
}
