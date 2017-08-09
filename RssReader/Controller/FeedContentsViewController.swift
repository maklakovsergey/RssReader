//
//  FeedContentsViewController.swift
//  RssReader
//
//  Created by sergey maklakov on 08.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit
import Block_KVO

class FeedContentsViewController: UIViewController {
    static func create() -> Self {
        return UIStoryboard.main.instantiate(viewControllerId: "FeedContentsViewController")
    }

    @IBOutlet weak var noFeedsView: UILabel!
    @IBOutlet weak var newsCollectionView: UICollectionView!

    private weak var refreshControl: UIRefreshControl?

    var feeds: [Feed]! {
        didSet {
            refreshFeeds()
        }
    }

    fileprivate var newsItems: [NewsItem] = []
    fileprivate var selectedNewsItem: NewsItem?
    fileprivate var requestsCount = 0

    var feedProvider: FeedProvider = Model.shared.feedProvider
    var newsProvider: NewsProvider = Model.shared.newsProvider

    override func viewDidLoad() {
        super.viewDidLoad()
        if feeds == nil {
            feedProvider.readFeeds(callback: { (feeds, error) in
                self.feeds = feeds
                self.presentErrorIfNeeded(error)
            })
        } else {
            refreshFeeds()
        }

        weak var weakSelf = self
        observe(newsCollectionView, property: "bounds", with: { (_, _, _, _) in
            weakSelf?.calculateCellSize()
        })

        let refreshControl = UIRefreshControl()
        self.refreshControl = refreshControl
        refreshControl.addTarget(self,
                                 action: #selector(FeedContentsViewController.refreshFeeds),
                                 for: .valueChanged)
        newsCollectionView.addSubview(refreshControl)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewsItem" {
            let newsContentVC = segue.destination as? NewsContentViewController
            newsContentVC?.newsItem = selectedNewsItem
        }
    }

    @objc private func refreshFeeds() {
        guard feeds != nil && view != nil else {
            return
        }
        noFeedsView.isHidden = feeds.count != 0
        requestsCount += feeds.count
        for feed in feeds {
            newsProvider.readNews(feed: feed, callback: handleNewsLoaded(items:error:))
        }
    }

    private func handleNewsLoaded(items: [NewsItem]?, error: Error?) {
        requestsCount -= 1
        if requestsCount == 0 {
            refreshControl?.endRefreshing()
        }
        if let theItems = items {
            newsItems.append(contentsOf: theItems)
            newsItems.sort(by: { $0.date > $1.date })
            newsCollectionView.reloadData()
        }
    }

    //updates cell size so it will contain several items per row
    private func calculateCellSize() {
        guard let flowLayout = newsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let viewWidth = newsCollectionView.bounds.size.width
        let minWidth = CGFloat(320)
        let aspectRatio = CGFloat(4)/CGFloat(3)
        var cellsPerRow = floor(viewWidth/minWidth)
        if cellsPerRow < 1 {
            cellsPerRow = 1
        }
        var itemSize = CGSize()
        itemSize.width = (viewWidth - flowLayout.minimumInteritemSpacing*(cellsPerRow-1)) / cellsPerRow
        itemSize.height = itemSize.width / aspectRatio
        flowLayout.estimatedItemSize = itemSize
    }
}

extension FeedContentsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let contentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedContentCell",
                                                             for: indexPath) as? FeedContentCell
        contentCell?.newsItem = newsItems[indexPath.item]
        return contentCell!
    }
}

extension FeedContentsViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedNewsItem = newsItems[indexPath.item]
        performSegue(withIdentifier: "showNewsItem", sender: self)
    }
}
