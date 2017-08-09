//
//  FeedsListController.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit

class FeedsListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var feedProvider: FeedProvider = Model.shared.feedProvider
    fileprivate var feeds: [Feed] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        readData()
    }

    @IBAction func addFeed(_ sender: Any) {
        presentFeedUrlRequest(url: nil, error: nil)
    }

    private func presentFeedUrlRequest(url: String?, error: Error?) {
        var message = "Введите адрес RSS ленты"
        if let theError = error {
            message += "\n" + theError.localizedDescription
        }
        let alert = UIAlertController(title: "Добавить",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let url = alert.textFields?.first?.text
            self.checkAndAddFeed(url: url!)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addTextField(configurationHandler: { (textField) in
            textField.keyboardType = .URL
            textField.text = url
        })
        present(alert, animated: true)
    }

    private func checkAndAddFeed(url: String) {
        spinner.startAnimating()
        feedProvider.check(url: url, callback: { (feed, error) in
            if let theFeed = feed {
                self.feedProvider.insert(feed: theFeed, callback: { (_) in
                    self.spinner.stopAnimating()
                    self.readData()
                })
            } else {
                self.spinner.stopAnimating()
                self.presentFeedUrlRequest(url: url, error: error)
            }
        })
    }

    private func readData() {
        spinner.startAnimating()
        feedProvider.readFeeds(callback: processReadData)
    }

    private func processReadData(_ feeds: [Feed]?, error: Error?) {
        spinner.stopAnimating()
        self.feeds = feeds ?? []
        tableView.reloadData()

        presentErrorIfNeeded(error)
    }

    fileprivate func displayFeedContents(feed: Feed) {
        let contentsVC = FeedContentsViewController.create()
        contentsVC.feeds = [feed]
        splitViewController?.showDetailViewController(contentsVC, sender: self)
    }
}

extension FeedsListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath)
        let feed = feeds[indexPath.item]
        cell.textLabel?.text = feed.name
        return cell
    }
}

extension FeedsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        displayFeedContents(feed: feeds[indexPath.item])
    }
}
