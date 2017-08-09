//
//  Error.swift
//  RssReader
//
//  Created by sergey maklakov on 08.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import Foundation

class AppError {
    static let domain = "RssReader"

    enum Code: Int {
        case invalidRssFormat
        case feedAlreadyExists
    }

    static let invalidRssFormat = error(code: .invalidRssFormat,
                                        message: "Адрес не содержит RSS ленту")
    static let feedAlreadyExists = error(code: .feedAlreadyExists,
                                        message: "Эта лента уже есть в списке")

    static func error(code: Code, message: String) -> Error {
        return NSError(domain: domain,
                       code: code.rawValue,
                       userInfo: [NSLocalizedDescriptionKey: message])
    }
}
