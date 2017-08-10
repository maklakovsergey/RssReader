//
//  NewsProvider.swift
//  RssReader
//
//  Created by sergey maklakov on 08.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

protocol NewsProvider {
    func readNews(feed: Feed, callback: (([NewsItem]?, Error?) -> Void)?)
}

class CachedNewsProvider: NewsProvider {
    private var storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    func readNews(feed: Feed, callback: (([NewsItem]?, Error?) -> Void)?) {
        Alamofire.request(feed.url).response { (response) in
            if response.error != nil {
                self.readFromDatabase(feed: feed) { (items, error) in
                    self.removeHtmlTags(news: items ?? [])
                    callback?(items, error)
                }
            } else {
                self.parse(data: response.data) { (items, error) in
                    if error == nil {
                        let theItems = items ?? []
                        self.saveToDatabase(feed: feed, items: theItems, callback: { (_) in
                            self.removeHtmlTags(news:theItems)
                            callback?(theItems, nil)
                        })
                    } else {
                        callback?(nil, error)
                    }
                }
            }
        }
    }

    private func parse(data: Data?, callback: (([NewsItem]?, Error?) -> Void)?) {
        var news: [NewsItem]?
        if let theData = data {
            let indexer = SWXMLHash.parse(theData)
            let items = indexer["rss"]["channel"]["item"].all
            news = []
            for item in items {
                if let newsItem = NewsItem(xmlIndexer: item) {
                    news!.append(newsItem)
                }
            }
        }
        if news != nil {
            DispatchQueue.main.async {
                callback?(news, nil)
            }
        } else {
            DispatchQueue.main.async {
                callback?(nil, AppError.invalidRssFormat)
            }
        }
    }

    private func readFromDatabase(feed: Feed, callback: (([NewsItem]?, Error?) -> Void)?) {
        storage.fetch(entityName: "DBNewsItem",
                      predicate: NSPredicate(format: "feedUrl == %@", feed.url.absoluteString),
                      callback: callback)
    }

    private func saveToDatabase(feed: Feed, items: [NewsItem], callback: ((Error?) -> Void)?) {
        for item in items {
            item.feedUrl = feed.url
        }
        storage.remove(entityName: "DBNewsItem",
                       predicate: NSPredicate(format: "feedUrl == %@", feed.url.absoluteString)) { (error) in
            if error == nil {
                self.storage.insert(objects: items,
                                    entityName: "DBNewsItem",
                                    callback: callback)
            } else {
                DispatchQueue.main.async {
                    callback?(error)
                }
            }
        }
    }

    /* In previous version I tried to display HTML as is, decode it before displaying. 
     There was an issue while decoding HTML on the cell level - the app crashes after 
     changing layout of the device. So I decided to remove all HTML tags 
     after receiving it from server and handle with news like an ordinary string
     */
    private func removeHtmlTags(news: [NewsItem]) {
        for item in news {
            item.title = NSAttributedString(htmlString: item.title)?.string ?? ""
            item.contents = NSAttributedString(htmlString: item.contents)?.string ?? ""
        }
    }
}
