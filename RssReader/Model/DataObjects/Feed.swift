//
//  Feed.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import CoreData

class Feed: DatabaseObject {
    let url: URL
    let name: String
    init(url: URL, name: String) {
        self.url = url
        self.name = name
    }

    required init?(managedObject: NSManagedObject) {
        guard let dbfeed = managedObject as? DBFeed else {
            return nil
        }
        guard let theUrl = URL(string: dbfeed.url ?? "") else {
            return nil
        }
        url = theUrl
        name = dbfeed.name ?? ""
    }

    func save(managedObject: NSManagedObject) {
        guard let dbfeed = managedObject as? DBFeed else {
            return
        }
        dbfeed.name = name
        dbfeed.url = url.absoluteString
    }

    var isValid: Bool {
        return !name.isEmpty
    }
}

extension Feed: Hashable {

    static func == (lhs: Feed, rhs: Feed) -> Bool {
        return lhs.url == rhs.url
    }

    var hashValue: Int { return url.hashValue }
}
