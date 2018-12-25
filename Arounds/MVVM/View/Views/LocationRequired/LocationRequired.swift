//
//  LocationRequired.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class LocationRequired: UIView {
    
    @IBOutlet weak var closButton: UIButton!
    static let shared = LocationRequired.loadFromNib()
    lazy var locationManager = CLLocationManager()
    class func loadFromNib() ->LocationRequired {
        
        let instance = UINib.init(nibName: "LocationRequired", bundle: nil).instantiate(withOwner: self, options: nil).first as! LocationRequired
        instance.frame = UIScreen.main.bounds
        
        return instance
    }
    
    func show(hide:Bool = false) {
        if hide == true {
            removeFromSuperview()
        } else {
           self.closButton.isHidden = LocationStatusTracker.shared.isNotDetermined()
            UIApplication.shared.keyWindow?.addSubview(self)
        }
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        if LocationStatusTracker.shared.isNotDetermined() {
            LocationManager.shared.allowRequest()
            locationManager.delegate = self
//            close(UIButton())
            return
        }
        
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
        
    }
    
    @IBAction func close(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "askingAccess") == false {
            NotificationRequired.shared.show(hide:
                UserDefaults.standard.bool(forKey: "notificationGranted"))
        }
        removeFromSuperview()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension LocationRequired: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.closButton.isHidden = status == .notDetermined
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            close(UIButton())
        }
    }
}
