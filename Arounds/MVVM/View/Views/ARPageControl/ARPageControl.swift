//
//  ARPageControl.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/27/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

fileprivate let selectedColor = "F35119"
fileprivate let deselectedColor = "F1EAEF"

class ARPageControl: UIStackView {
  
    var selected:Int = 0 {
        didSet{
            if let subview = arrangedSubviews[selected].subviews.first,
                let oldView = arrangedSubviews[oldValue].subviews.first {
                
                selectView(selectingView: oldView, select: false)
                selectView(selectingView: subview, select: true)
            }
        }
    }

    func selectView(selectingView: UIView, select: Bool) {
        selectingView.backgroundColor = UIColor.withHex( select ? selectedColor : deselectedColor)
    }
    
    
    class func loadFromNib(selected: Int = 0, onView: UIView) -> ARPageControl {
        let instance = UINib(nibName: "ARPageControl", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ARPageControl
        instance.selected = selected
       
        onView.addSubview(instance)
        instance.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
        
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: onView, attribute: $0, relatedBy: .equal, toItem: instance, attribute: $0, multiplier: 1, constant: 0)
        })
        return instance
    }

}
