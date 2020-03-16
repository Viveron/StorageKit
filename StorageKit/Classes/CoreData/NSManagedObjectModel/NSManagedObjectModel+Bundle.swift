//
//  NSManagedObjectModel+Bundle.swift
//  StorageKit
//
//  Created by Victor Shabanov on 17.03.2020.
//  Copyright © 2019 Victor Shabanov. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectModel {

    convenience init?(name: String, bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: name, withExtension: "momd") else {
            return nil
        }

        self.init(contentsOf: url)
    }
}
