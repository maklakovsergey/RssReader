//
//  CoreDataFeedProvider.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class CoreDataFeedProvider: FeedProvider {
    private var storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    func readFeeds(callback: (([Feed]?, Error?) -> Void)?) {
        storage.fetch(entityName: "DBFeed",
                      predicate: nil,
                      callback: callback)
    }

    func insert(feed: Feed, callback: ((Error?) -> Void)?) {
        storage.insert(objects: [feed],
                       entityName: "DBFeed",
                       callback: callback)
    }

    func check(url: String, callback: ((Feed?, Error?) -> Void )?) {
        let urlString = url.trimmingCharacters(in: .whitespaces).lowercased()
        guard let theUrl = URL(string: urlString) else {
            let error = NSError(domain: NSURLErrorDomain,
                                code: NSURLErrorBadURL,
                                userInfo: [NSLocalizedDescriptionKey: "Неправильный адрес"])
            DispatchQueue.main.async {
                callback?(nil, error)
            }
            return
        }

        checkIfUrlExistsInDatabase(url: theUrl) { (exists, error) in
            if exists == true {
                DispatchQueue.main.async {
                    callback?(nil, AppError.feedAlreadyExists)
                }
            } else if exists == false {
                self.tryGetFeed(url: theUrl, callback: callback)
            } else {
                DispatchQueue.main.async {
                    callback?(nil, error)
                }
            }
        }
    }

    private func checkIfUrlExistsInDatabase(url: URL,
                                            callback: ((Bool?, Error?) -> Void)?) {
        storage.fetch(entityName: "DBFeed",
                      predicate: NSPredicate(format: "url==%@", url.absoluteString)) { (feed: [Feed]?, error) in
                        if let theFeed = feed {
                            callback?(theFeed.count > 0, nil)
                        } else {
                            callback?(nil, error)
                        }
        }
    }

    private func tryGetFeed(url: URL,
                            callback: ((Feed?, Error?) -> Void)?) {
        Alamofire.request(url).response { (response) in
            if let error = response.error {
                DispatchQueue.main.async {
                    callback?(nil, error)
                }
            } else {
                var title = ""
                if let data = response.data {
                    let indexer = SWXMLHash.parse(data)
                    title = indexer["rss"]["channel"]["title"].element?.text ?? ""
                }
                if !title.isEmpty {
                    let feed = Feed(url: url, name: title)
                    DispatchQueue.main.async {
                        callback?(feed, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        callback?(nil, AppError.invalidRssFormat)
                    }
                }
            }
        }
    }
}
