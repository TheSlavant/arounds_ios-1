//
//  UserTypingView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class UserTypingView: UIView {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet var typingImage: [UIImageView]!
    @IBOutlet var views: [UIView]!
    var selectedIndex:Int = 0
    var stop = true {
        didSet {
            if stop == false {
//                let selected = self.views[selectedIndex]
//                selected.constraints.filter({$0.firstAttribute == .height}).first?.constant = 7
//                typingImage[selectedIndex].image = UIImage.init(named: "typing_gray")
//                views.forEach({$0.constraints.filter({$0.firstAttribute == .height}).first?.constant = 7})
//                typingImage.forEach({$0.image = UIImage.init(named: "typing_gray")})
//                self.layoutIfNeeded()
            }

        }
    }
    
    class func loadFromNib() -> UserTypingView {
        let instance = UINib.init(nibName: "UserTypingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UserTypingView
      
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            instance.dropShadow(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), opacity: 0.3, offSet: CGSize(width: -2.0, height: 2.0), radius: 5, scale: true, view: instance.shadowView)
        }
        
        instance.clipsToBounds = false
        return instance
    }
    
    
    func start(dilay: TimeInterval, index: Int = 1) {
        if stop == true {
            return
        }
        let view = self.views[index]
        let selected = self.views[selectedIndex]
        
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: dilay, animations: {
            selected.constraints.filter({$0.firstAttribute == .height}).first?.constant = 7
            view.constraints.filter({$0.firstAttribute == .height}).first?.constant = 13
            self.typingImage[index].image = UIImage.init(named: "typing_red")
            self.layoutIfNeeded()
        }) { (finish) in
            self.typingImage[self.selectedIndex].image = UIImage.init(named: "typing_gray")
            self.selectedIndex = index

            if index == 2 {
                self.start(dilay: dilay, index: 0)
            } else {
                self.start(dilay: dilay, index: index + 1)
            }
        }
        
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true, view: UIView) {
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
        
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

}

