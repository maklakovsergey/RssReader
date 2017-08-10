//
//  NewsContentViewController.swift
//  RssReader
//
//  Created by sergey maklakov on 09.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit
import WebKit
import PureLayout

class NewsContentViewController: UIViewController {
    var newsItem: NewsItem!

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    private weak var webView: WKWebView?

    fileprivate enum DataSource {
        case url
        case content
    }
    fileprivate var dataSource: DataSource!

    override func viewDidLoad() {
        let webView = WKWebView(frame: webViewContainer.bounds)
        self.webView = webView
        webViewContainer.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()
        webView.navigationDelegate = self

        title = newsItem.title
        if newsItem?.url != nil {
            loadData(source: .url)
        } else {
            loadData(source: .content)
        }
    }

    @IBAction func share(_ sender: Any) {
        guard newsItem != nil else {
            return
        }
        var shareItems: [Any] = [newsItem.title]
        if let url = newsItem.url {
            shareItems.append(url)
        }
        let activityController = UIActivityViewController(activityItems: shareItems,
                                                          applicationActivities: nil)
        present(activityController, animated: true)
    }

    fileprivate func loadData(source: DataSource) {
        dataSource = source
        switch source {
        case .url:
            if let url = newsItem?.url {
                webView?.load(URLRequest(url: url))
            }
        case .content:
            webView?.loadHTMLString(newsItem.contents, baseURL: nil)
        }
    }
}

extension NewsContentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
        if dataSource == .url {
            loadData(source: .content)
        }
    }

}
