//
//  AppDelegateFirebase.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import SVProgressHUD
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import Firebase
import UIKit

class AppDelegateFirebase: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert] , completionHandler: { (granted, error) in
            UserDefaults.standard.set(true, forKey: "askingAccess")
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.async {
                NotificationRequired.shared.show(hide: granted)
            }
            
            if error != nil {
                
            } else {
                
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        ConnectToFCM()
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        ConnectToFCM()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        // This notification is not auth related, developer should handle it.
    }
    
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        if Auth.auth().canHandleNotification(notification.userInfo ?? [AnyHashable : Any]()) {
            //            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
    }
    
    func ConnectToFCM() {
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if let token = InstanceID.instanceID().token() {
            print("DCS: " + token)
            if ARUser.currentUser != nil {
                Database.database().reference().child("users").child(ARUser.currentUser?.id ?? "").updateChildValues(["DCS" : token])
            }
            
            UserDefaults.standard.set(token, forKey: "DCS")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        // URL not auth related, developer should handle it.
        return true
    }
    
}

extension AppDelegateFirebase: MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "com.Arounds"), object: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let aps = userInfo["aps"] as? [String: Any],
            let alert = aps["alert"] as? [String: Any] {
            
            let body = alert["body"] as? String
            let title = alert["title"] as? String
            
            if let body = body,
                body.contains("Новое сообщение") == true,
                let chatRoomID = userInfo["chatRoomID"] as? String {
                self.openChat(chatRoomID: chatRoomID)
            } else if let body = body,
                body.contains("Ваш профиль") == true,
                let senderID = userInfo["senderID"] as? String {
                self.openProfile(senderID: senderID)
            } else if title ?? "" == "Радар:" {
                self.openRadar()
            }
            
        }
        
    }
    
    func openChat(chatRoomID: String) {
        if let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarVC {
            tabBarVC.homeTabBar?.selectItem(at: 1)
            let chatListVC = (tabBarVC.viewControllers![1] as? UINavigationController)?.viewControllers.first as? ChatListVC
            chatListVC?.fromNotificationChatID = chatRoomID
        }
    }
    
    func openProfile(senderID: String) {
        SVProgressHUD.show()
        Database.Users.user(userID: senderID) { (user) in
            SVProgressHUD.dismiss(completion: {
                if let user = user {
                    let vc = ProfileVC.instantiate(from: .Profile)
                    vc.viewModel = OtherProfileViewModel.init(with: user)
                    let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarVC
                    (tabBarVC?.viewControllers![tabBarVC?.selectedIndex ?? 0] as? UINavigationController)?.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    func openRadar() {
        if let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarVC {
            tabBarVC.homeTabBar?.selectItem(at: 1)
            let chatListVC = (tabBarVC.viewControllers![1] as? UINavigationController)?.viewControllers.first as? ChatListVC
            if let chatVC = chatListVC?.presentedViewController as? OneToOneVC {
                chatVC.navigationView.didClickBack?(UIButton())
                chatListVC?.openRadarChat = true
            } else {
                chatListVC?.presentedViewController?.dismiss(animated: false, completion: {
                })
                chatListVC?.openRadarChat = true
            }
        }
    }
    
    
}
