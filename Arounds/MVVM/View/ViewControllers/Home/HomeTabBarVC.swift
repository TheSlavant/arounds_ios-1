//
//  HomeTabBarVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase
import UIKit

class HomeTabBarVC: UITabBarController {
    
    let locationSharing = LocationSharingManager()
    var homeTabBar: HomeTabBar?
    var profielBlock: ARProfileBlock?
    var messageBlock: ARMessageBlock?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.homeTabBar = HomeTabBar.loadFromNib(onView: tabBar)
        self.homeTabBar?.delegate = self
        homeTabBar?.selectItem(at: 0)
        
        if let profileVC = (viewControllers?.last as? UINavigationController)?.viewControllers.first as? ProfileVC {
            if let user = ARUser.currentUser {
                profileVC.viewModel = MyProfileViewModel.init(with: user)
            }
        }
        
        self.showEdit()
        
        LocationManager.shared.allowRequest()
        LocationStatusTracker.shared.startTracking()
        locationSharing.start(interval: 10)
        
        subscribeOnBlock()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showEdit() {
        if ARUser.currentUser?.isUpdated == false {
            DispatchQueue.main.async {
                let whiteView = UIView.init(frame: UIScreen.main.bounds)
                whiteView.backgroundColor = .white
                self.view.addSubview(whiteView)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                    whiteView.alpha = 0
                    whiteView.isHidden = true
                    whiteView.removeAllSubviews()
                })
            }
            

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                let vc = EditVC.instantiate(from: .Profile)
                vc.viewModel = FirstUpdateProfileViewModel(with: ARUser.currentUser!)
                self?.present(vc, animated: true, completion: {
                    self?.homeTabBar?.selectItem(at: 3)
                })
            }
        }
        
    }
}

extension HomeTabBarVC: HomeTabBarDelegate {
    
    func didSelect(item: HomeTabBarItem, index: Int, tabBar: HomeTabBar) {
        selectedIndex = index
        if let arrayVC = viewControllers {
            selectedViewController = arrayVC[index]
            if index == 0,
                let mapVC = (selectedViewController as? UINavigationController)?.viewControllers.first as? MapVC,
                let locManager = mapVC.locManager {
                locManager.startUpdatingLocation()
            }
        }
    }
}

extension HomeTabBarVC {
    
    func subscribeOnBlock() {
        
        let profBlockRef = Database.database().reference().child(kProfile_block)
        let msgBlockRef = Database.database().reference().child(kMessage_block).child(ARUser.currentUser?.id ?? "")
        
        profBlockRef.observe(.value, with: { [weak self] (snapshot) in
            if let dict = snapshot.value as? [String: [String: Any]],
                let meBlock = dict.filter({ ($0.value["profileID"] as? String ?? "") == ARUser.currentUser?.id ?? ""}).first {
                if self?.profielBlock == nil {
                    self?.profielBlock = ARProfileBlock.init(with: meBlock)
                } else {
                    self?.profielBlock?.prefil(dict: meBlock)
                }
                self?.profielBlock?.save()
                self?.profielBlock?.chackLavel()
            } else {
                let newBlockID = profBlockRef.childByAutoId().key
                profBlockRef.updateChildValues([newBlockID : ARProfileBlock.newBlockModel()])
            }
        })
        
        
        msgBlockRef.observe(.value) { [weak self] (snapshot) in
            
            if snapshot.exists(), let dict = snapshot.value as? [String: Any] {
                
                if self?.messageBlock == nil {
                    self?.messageBlock = ARMessageBlock.init(with: dict)
                } else {
                    self?.messageBlock?.prefil(dict: dict)
                }
                self?.messageBlock?.save()
                self?.messageBlock?.chackLavel()
            }
            
        }
    }
    
}






