//
//  NotificationRequired.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationRequired: UIView {
    
    @IBOutlet weak var closeButton: UIButton!
    static let shared = NotificationRequired.loadFromNib()
    class func loadFromNib() -> NotificationRequired {
        
        let instance = UINib.init(nibName: "NotificationRequired", bundle: nil).instantiate(withOwner: self, options: nil).first as! NotificationRequired
        instance.frame = UIScreen.main.bounds
        
        return instance
    }
    
    func show(hide:Bool) {
        DispatchQueue.main.async { [weak self] in
            if hide == true {
                self?.removeFromSuperview()
            } else {
                self?.closeButton.isHidden = UserDefaults.standard.bool(forKey: "askingAccess") == false
                UIApplication.shared.keyWindow?.addSubview(self ?? UIView())
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        show(hide: true)
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "askingAccess") == true {
            
            self.closeButton.isHidden = false
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert] , completionHandler: { [weak self] (granted, error) in
            UserDefaults.standard.set(true, forKey: "askingAccess")
            UserDefaults.standard.set(granted, forKey: "notificationGranted")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                self?.closeButton.isHidden = false
            }
            if error != nil {
                
            } else {
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.closeTapped(UIButton())
                }
            }
        })
        //        show(hide: true)
        //        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
        //            UIApplication.shared.canOpenURL(settingsUrl) {
        //            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
        //                print("Settings opened: \(success)") // Prints true
        //            })
        //        }
        
    }
    
}
