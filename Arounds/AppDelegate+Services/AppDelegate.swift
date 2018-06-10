//
//  AppDelegate.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/26/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SVProgressHUD
import GoogleMaps
import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    final var services: [UIApplicationDelegate] = [
        AppDelegateFirebase()
    ]
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyBdYqlW_lvrhZrmItUZ5rV3AZ0hnGvOG3w")
        
        for service in self.services {
            _ = service.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        //
        IQKeyboardManager.shared.enable = true
        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor.withHex("4F4F6F"),
            NSAttributedStringKey.font: UIFont(name: "MontserratAlternates-Bold", size: 26)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attrs
        SVProgressHUD.setBackgroundColor(.lightGray)
        SVProgressHUD.setDefaultMaskType(.clear)
        
        if ARUser.currentUser != nil {
            AppCoordinator.showHome(fromLogin: false, window : window)
        }

        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        for service in self.services {
            _ = service.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        for service in self.services {
            _ = service.application?(application, didReceive: notification)
        }
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        for service in self.services {
            _ = service.application?(application, open: url, options: options)
        }
        // URL not auth related, developer should handle it.
        return true
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if  ARUser.currentUser != nil {
            LocationStatusTracker.shared.startTracking()
        }
        
    }
    
}

