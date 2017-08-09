//
//  FeedContentCell.swift
//  RssReader
//
//  Created by sergey maklakov on 08.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit

class FeedContentCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    var newsItem: NewsItem! {
        didSet {
            self.titleLabel.text = self.newsItem.title
            self.contentLabel.text = self.newsItem.contents
            dateLabel.text = newsItem.date.description
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutAttributes {
        widthConstraint.constant = layoutAttributes.size.width
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        return attributes
    }
}
