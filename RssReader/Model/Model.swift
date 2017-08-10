//
//  Model.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import Foundation

class Model {
    lazy var storage: Storage = {
        return CoreDataStorage()
    }()

    lazy var feedProvider: FeedProvider = {
        return CoreDataFeedProvider(storage: self.storage)
    }()

    lazy var newsProvider: NewsProvider = {
        return CachedNewsProvider(storage: self.storage)
    }()

    static let shared: Model = Model()
}
