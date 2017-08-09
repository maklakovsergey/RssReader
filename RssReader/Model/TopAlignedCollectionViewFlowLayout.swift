//
//  TopAlignedCollectionViewFlowLayout.swift
//  RssReader
//
//  Created by sergey maklakov on 09.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit

// https://stackoverflow.com/a/35702844

class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attrs = super.layoutAttributesForElements(in: rect) {
            var baseline: CGFloat = -2
            var sameLineElements = [UICollectionViewLayoutAttributes]()
            for element in attrs where element.representedElementCategory == .cell {
                let frame = element.frame
                let centerY = frame.midY
                if abs(centerY - baseline) > 1 {
                    baseline = centerY
                    TopAlignedCollectionViewFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements)
                    sameLineElements.removeAll()
                }
                sameLineElements.append(element)
            }
            // align one more time for the last line
            TopAlignedCollectionViewFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements)
            return attrs
        }
        return nil
    }

    private class func alignToTopForSameLineElements(sameLineElements: [UICollectionViewLayoutAttributes]) {
        if sameLineElements.count < 1 {
            return
        }
        let sorted = sameLineElements.sorted { (obj1, obj2) -> Bool in
            let height1 = obj1.frame.size.height
            let height2 = obj2.frame.size.height
            let delta = height1 - height2
            return delta <= 0
        }
        if let tallest = sorted.last {
            for obj in sameLineElements {
                obj.frame = obj.frame.offsetBy(dx: 0, dy: tallest.frame.origin.y - obj.frame.origin.y)
            }
        }
    }
}
