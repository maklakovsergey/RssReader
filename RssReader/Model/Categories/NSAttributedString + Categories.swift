//
//  NSAttributedString + Categories.swift
//  RssReader
//
//  Created by sergey maklakov on 09.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit

extension NSAttributedString {
    convenience init?(htmlString: String) {
        guard let data = htmlString.data(using: .utf8) else {
            return nil
        }
        let options: [String: Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
        ]
        assert(Thread.isMainThread)
        do {
            try self.init(data: data, options: options, documentAttributes: nil)
        } catch {
            print(error)
            return nil
        }
    }
}
