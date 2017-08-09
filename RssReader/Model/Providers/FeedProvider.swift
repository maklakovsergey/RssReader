//
//  FeedProvider.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import Foundation

protocol FeedProvider {
    func readFeeds(callback: (([Feed]?, Error?) -> Void)?)
    func insert(feed: Feed, callback: ((Error?) -> Void)?)
    func check(url: String, callback: ((Feed?, Error?) -> Void )?)
}
