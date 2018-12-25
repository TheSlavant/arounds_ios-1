//
//  ViewController+Extention.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 8/31/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension UIViewController {

    func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}



