//
//  HomeTabBar.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

protocol HomeTabBarDelegate {
    func didSelect(item: HomeTabBarItem, index: Int, tabBar: HomeTabBar)
}

class HomeTabBar: UIView {
    @IBOutlet weak var stackView: UIStackView!
    
    lazy var tabBarItems = [HomeTabBarItem.loadFromNib(with: .map),
                            HomeTabBarItem.loadFromNib(with: .star),
                            HomeTabBarItem.loadFromNib(with: .chat),
                            HomeTabBarItem.loadFromNib(with: .search),
                            HomeTabBarItem.loadFromNib(with: .profile)]
    
    var delegate: HomeTabBarDelegate?
    var selectedItem: HomeTabBarItem? {
        didSet{
            
        }
    }
    
    class func loadFromNib(selected: Int = 2, onView: UIView) -> HomeTabBar {
        let instance = UINib(nibName: "HomeTabBar", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! HomeTabBar
        instance.selectItem(at: selected)
        //
        onView.addSubview(instance)
        instance.frame.size.height = onView.frame.height
        instance.frame.size.width = UIScreen.main.bounds.size.width
        //
        instance.startListener()
        instance.setupItems()
        //
        return instance
    }
    
    private func setupItems()  {
        for obj in tabBarItems {
            stackView.addArrangedSubview(obj)
        }
    }
    
    func selectItem(at index:Int) {
        // close
        if let selectedItem = selectedItem {
        selectedItem.imageView.tintColor = UIColor.withHex("4F4F6F")
        }
        // open
        if tabBarItems.count > index {
            selectedItem = tabBarItems[index]
            selectedItem?.imageView.tintColor = UIColor.withHex("F94865")
        }
        delegate?.didSelect(item: selectedItem!, index: index, tabBar: self)
    }
    
    func open(constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.3) {
            constraint.constant = 65
            self.layoutIfNeeded()
        }
    }
    
    func close(constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.3) {
            constraint.constant = 45
        }
    }
    
    func startListener() {
        for item in tabBarItems {
            item.didSelect = { [weak self] sender in
                guard let weakSelf = self else {return}
                weakSelf.selectItem(at: weakSelf.tabBarItems.index(of: item)!)
            }
        }
    }
}
