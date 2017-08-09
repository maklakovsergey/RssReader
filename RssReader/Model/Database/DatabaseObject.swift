//
//  DatabaseObject.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import CoreData

protocol DatabaseObject {
    init?(managedObject: NSManagedObject)
    func save(managedObject: NSManagedObject)
}
