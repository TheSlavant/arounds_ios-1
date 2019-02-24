//
//  AppCoordinator.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/30/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class AppCoordinator {
    
    static func showHome(fromLogin: Bool = false, window : UIWindow? = UIApplication.shared.keyWindow) {
        let nc = UIViewController.instantiate(from: .Home, identifier: "HomeTabBar")
        
        
        if fromLogin == true {
            window?.rootViewController?.present(nc, animated: true, completion: nil)
        } else {
            window?.rootViewController = nc
            window?.makeKeyAndVisible()
        }
    }
    
}
