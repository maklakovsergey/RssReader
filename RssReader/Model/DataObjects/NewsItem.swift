//
//  NewsItem.swift
//  RssReader
//
//  Created by sergey maklakov on 08.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//
import CoreData
import SWXMLHash

class NewsItem: DatabaseObject {
    var guid: String = UUID().uuidString
    var url: URL?
    var title: String = ""
    var contents: String = ""
    var date: Date = Date()
    var feedUrl: URL?

    required init() {
    }

    required init?(managedObject: NSManagedObject) {
        guard let dbnewsItem = managedObject as? DBNewsItem else {
            return nil
        }
        guid = dbnewsItem.guid ?? UUID().uuidString
        if let urlString = dbnewsItem.url {
            url = URL(string: urlString)
        }
        title = dbnewsItem.title ?? ""
        contents = dbnewsItem.contents ?? ""
        date = (dbnewsItem.date as Date?) ?? Date()
        if let urlString = dbnewsItem.feedUrl {
            feedUrl = URL(string: urlString)
        }
        if !isValid {
            return nil
        }
    }

    private lazy var xmlDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        return formatter
    }()

    required init?(xmlIndexer: XMLIndexer) {
        guid = xmlIndexer["guid"].element?.text ?? UUID().uuidString

        if let urlString = xmlIndexer["link"].element?.text {
            url = URL(string: urlString)
        }
        title = xmlIndexer["title"].element?.text ?? ""
        contents = xmlIndexer["description"].element?.text ?? ""
        if let dateStr = xmlIndexer["pubDate"].element?.text {
            date = xmlDateFormatter.date(from: dateStr) ?? Date()
        }

        if !isValid {
            return nil
        }
    }

    func save(managedObject: NSManagedObject) {
        guard let dbnewsItem = managedObject as? DBNewsItem else {
            return
        }
        dbnewsItem.guid = guid
        dbnewsItem.url = url?.absoluteString
        dbnewsItem.title = title
        dbnewsItem.contents = contents
        dbnewsItem.date = date as NSDate
        dbnewsItem.feedUrl = feedUrl?.absoluteString
    }

    var isValid: Bool {
        return !guid.isEmpty && !title.isEmpty && !contents.isEmpty
    }
}

extension NewsItem: Hashable {
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        return lhs.guid == rhs.guid
    }

    var hashValue: Int { return guid.hashValue }
}
