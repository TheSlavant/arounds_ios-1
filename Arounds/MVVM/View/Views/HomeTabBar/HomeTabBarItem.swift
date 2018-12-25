//
//  HomeTabBarItem.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

enum HomeTabBarItemType: String {
    case map = "map_icon"
//    case star = "star_icon"
    case chat = "chat_icon"
    case search = "search_icon"
    case profile = "profile_icon"
}

class HomeTabBarItem: UIView {
    
    @IBOutlet weak var bargeView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var didSelect : ((HomeTabBarItem) -> Void)?
    var type: HomeTabBarItemType = .map
    
    
    class func loadFromNib(with type: HomeTabBarItemType) -> HomeTabBarItem {
        let instance = UINib(nibName: "HomeTabBarItem", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! HomeTabBarItem
        instance.type = type
        instance.imageView.image = UIImage(named: type.rawValue)
        instance.bargeView.layer.cornerRadius = instance.bargeView.frame.height/2
        return instance
    }
    
    @IBAction func didClick(_ sender: UIButton) {
        didSelect?(self)
    }
    
}
