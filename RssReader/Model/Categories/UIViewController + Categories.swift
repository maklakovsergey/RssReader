//
//  UIViewController + Categories.swift
//  RssReader
//
//  Created by sergey maklakov on 08.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit

extension UIViewController {

    func presentErrorIfNeeded(_ error: Error?) {
        guard let theError = error else {
            return
        }

        let alert = UIAlertController(title: nil,
                                      message: theError.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
