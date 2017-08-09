//
//  UIStoryboard + Categories.swift
//  RssReader
//
//  Created by sergey maklakov on 08.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    func instantiate<T>(viewControllerId: String) -> T {
        let viewController = instantiateViewController(withIdentifier: viewControllerId) as? T
        return viewController!
    }
}
