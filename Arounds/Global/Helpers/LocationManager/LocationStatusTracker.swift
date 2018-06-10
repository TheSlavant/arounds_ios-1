//
//  CountyPhoneManager.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

import CoreLocation
import UIKit

class LocationStatusTracker: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationStatusTracker()
    lazy var locationManager = CLLocationManager()
    var controller: UIAlertController?
    override init() {
        super.init()
    }
    
    func startTracking() {
        self.locationManager.delegate = self;
        chack(status: CLLocationManager.authorizationStatus())
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        chack(status: status)
    }
    
    func chack(status: CLAuthorizationStatus) {
        if status == .denied  {
//            self.controller = UIAlertController.init(title:"ItIsImportant".localized , message: "YouMustConnectYourLocation".localized, preferredStyle: UIAlertControllerStyle(rawValue: 1)!)
//
//            self.controller?.addAction(UIAlertAction.init(title: "Ok".localized, style: UIAlertActionStyle.cancel, handler: { (action) in
//                DispatchQueue.main.async {
//                    _ = sharedApp?.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
//
//                }
//            }))
//
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                self.controller?.modalPresentationStyle = .popover
//                if let popoverPresentationController = self.controller?.popoverPresentationController {
//                    popoverPresentationController.sourceView = UIApplication.shared.keyWindow?.rootViewController?.view
//                }
//            }
//
//            if let vc = self.controller {
//                sharedApp?.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
//            }
        }

    }
    
}
