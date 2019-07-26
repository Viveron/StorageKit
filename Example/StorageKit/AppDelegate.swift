//
//  AppDelegate.swift
//  StorageKit
//
//  Created by Victor Shabanov on 07/25/2019.
//  Copyright (c) 2019 Victor Shabanov. All rights reserved.
//

import UIKit
import StorageKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        storageExample()
        
        return true
    }
    
    func storageExample() {
        guard let storage = CoreDataStorage(model: "StorageModel", protection: .completeUnlessOpen) else {
            return
        }
        
        storage.load { loadError in
            guard loadError == nil else {
                return
            }
            
            [" Note content 1",
             " Note content 2",
             " Note content 3"].forEach { text in
                let note = NoteManagedObject.create(in: storage.mainManagedObjectContext)
                note.text = text
            }
            
            let predicate = NSPredicate(format: "ANY text CONTAINS[c] %@", "3")
            if let isExist = try? NoteManagedObject.exist(in: storage.mainManagedObjectContext, predicate), isExist {
                storage.clear {
                    if $0 == nil {
                        print("Clear is done...")
                    }
                }
            } else {
                storage.mainManagedObjectContext.asyncSaveToStore {
                    if $0 == nil {
                        print("Save is done...")
                    }
                }
            }
        }
    }
}
