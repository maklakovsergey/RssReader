//
//  Storage.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import CoreData

protocol Storage {
    func fetch<T>(entityName: String,
                  predicate: NSPredicate?,
                  callback: (([T]?, Error?) -> Void)?) where T: DatabaseObject
    func insert<T>(objects: [T],
                   entityName: String,
                   callback: ((Error?) -> Void)?) where T: DatabaseObject
    func remove(entityName: String,
                predicate: NSPredicate?,
                callback: ((Error?) -> Void)?)
}
