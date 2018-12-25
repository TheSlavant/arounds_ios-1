//
//  FirstPopup.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class FirstPopup: UIView {
   
    @IBOutlet weak var shadowView: UIView!

    class func loadFromNib() -> FirstPopup {
        let instance = UINib.init(nibName: "FirstPopup", bundle: nil).instantiate(withOwner: self, options: nil).first as! FirstPopup
        instance.frame = UIScreen.main.bounds
        return instance
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.dropShadow(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), offSet: CGSize(width: -2.0, height: 2.0), view: self.shadowView)
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.3, offSet: CGSize, radius: CGFloat = 7, scale: Bool = true, view: UIView) {
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
        
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    @IBAction func feedBackButton(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.removeFromSuperview()
        }) { (finish) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                FeedBack.loadFromNib().show()
            })
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func acceptButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.removeFromSuperview()
        }) { (finish) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                SecoundPopup.loadFromNib().show()
            })
        }
    }

}
