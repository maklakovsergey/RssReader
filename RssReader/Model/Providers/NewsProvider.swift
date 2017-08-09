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

class WebNewsProvider: NewsProvider {
    func readNews(feed: Feed, callback: (([NewsItem]?, Error?) -> Void)?) {
        Alamofire.request(feed.url).response { (response) in
            if let error = response.error {
                DispatchQueue.main.async {
                    callback?(nil, error)
                }
            } else {
                self.parse(data: response.data, callback: callback)
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
                self.removeHtmlTags(news: news!)
                callback?(news, nil)
            }
        } else {
            DispatchQueue.main.async {
                callback?(nil, AppError.invalidRssFormat)
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
