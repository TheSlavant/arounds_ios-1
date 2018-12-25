    //
    //  AppDelegate.swift
    //  Arounds
    //
    //  Created by Samvel Pahlevanyan on 4/26/18.
    //  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
    //
    import Firebase
    import SVProgressHUD
    import GoogleMaps
    import IQKeyboardManagerSwift
    import UIKit
    import Fabric
    import Crashlytics
    import StoreKit
    import UserNotifications
    import FirebaseCore
    import FirebaseMessaging
    import FirebaseInstanceID
    import UIKit
//    import GoogleAnalytics
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
//        final var services: [UIApplicationDelegate] = [
//            AppDelegateFirebase()
//        ]
        
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           
            FirebaseApp.configure()
            Database.database().isPersistenceEnabled = false
            
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            
            UIApplication.shared.applicationIconBadgeNumber = 0

            FeedBackLogic.shared.lastLogin()

            GMSServices.provideAPIKey("AIzaSyAWzybms-NYN9NPtGLoBzbnEBkg341Ct6c")
            
            IQKeyboardManager.shared.enable = true
            let attrs = [
                NSAttributedString.Key.foregroundColor: UIColor.withHex("4F4F6F"),
                NSAttributedString.Key.font: UIFont(name: "MontserratAlternates-Bold", size: 26)!
            ]
            
            UINavigationBar.appearance().titleTextAttributes = attrs
            SVProgressHUD.setBackgroundColor(.lightGray)
            SVProgressHUD.setDefaultMaskType(.clear)
            
            if ARUser.currentUser != nil {
                AppCoordinator.showHome(fromLogin: false, window : window)
            }
            
            Fabric.with([Crashlytics.self])
            
//            Database.database().reference().child("profile-block").removeValue()
            
//            AuthApi().login(with: "+3749891x0231" , completion: { (error, user) in
//
//            })
            
            //        UserDefaults.standard.bool(forKey: "kAgreeTermsOfUse") != true
            //
            
//            guard let gai = GAI.sharedInstance() else {
//                assert(false, "Google Analytics not configured correctly")
//            }
//            gai.tracker(withTrackingId: "YOUR_TRACKING_ID")
//            // Optional: automatically report uncaught exceptions.
//            gai.trackUncaughtExceptions = true
//            
//            // Optional: set Logger to VERBOSE for debug information.
//            // Remove before app release.
//            gai.logger.logLevel = .verbose;
            return true
        }
       
        func requestReview() {
            SKStoreReviewController.requestReview()
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

//        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//
//        }
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)
            Messaging.messaging().apnsToken = deviceToken

        }
        
        func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//            for service in self.services {
//                _ = service.application?(application, didReceive: notification)
//            }
            if Auth.auth().canHandleNotification(notification.userInfo ?? [AnyHashable : Any]()) {
                //            completionHandler(UIBackgroundFetchResult.noData)
                return
            }

        }
        
        func application(_ application: UIApplication, open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//            for service in self.services {
//                _ = service.application?(application, open: url, options: options)
//            }
            if Auth.auth().canHandle(url) {
                return true
            }

            // URL not auth related, developer should handle it.
            return true
        } 
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            application.applicationIconBadgeNumber = 0

//            for service in self.services {
//                service.applicationDidBecomeActive?(application)
//            }
            
//            LocationRequired.shared.show(hide:
//                CLLocationManager.authorizationStatus() != .denied)
            
//            if UserDefaults.standard.bool(forKey: "askingAccess") == true {
//                NotificationRequired.shared.show(hide:
//                    UIApplication.shared.isRegisteredForRemoteNotifications)
//            }
            ConnectToFCM()
            if  ARUser.currentUser != nil {
                LocationStatusTracker.shared.startTracking()
            }
            
        }
        
        func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
            ConnectToFCM()
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

    }
    

    extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
        
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
