//
//  NotificationRequired.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class NotificationRequired: UIView {
    
    static let shared = NotificationRequired.loadFromNib()
    
    class func loadFromNib() ->NotificationRequired {
        
        let instance = UINib.init(nibName: "NotificationRequired", bundle: nil).instantiate(withOwner: self, options: nil).first as! NotificationRequired
        instance.frame = UIScreen.main.bounds
        
        return instance
    }
    
    func show(hide:Bool) {
        if hide == true {
            removeFromSuperview()
        } else {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        
        if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }

    }
    //    func hide() {
//        removeFromSuperview()
//    }

    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}