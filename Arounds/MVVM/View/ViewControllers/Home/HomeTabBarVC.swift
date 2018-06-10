//
//  HomeTabBarVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class HomeTabBarVC: UITabBarController {
    
    let locationSharing = LocationSharingManager()
    var homeTabBar: HomeTabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.homeTabBar = HomeTabBar.loadFromNib(onView: tabBar)
        self.homeTabBar?.delegate = self
        homeTabBar?.selectItem(at: 2)
        
        if let profileVC = (viewControllers?.last as? UINavigationController)?.viewControllers.first as? ProfileVC {
            if let user = ARUser.currentUser {
                profileVC.viewModel = MyProfileViewModel.init(with: user)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "kAgreeTermsOfUse") == true {
            self.showEdit()
        }
        
        LocationManager.shared.allowRequest()
        LocationStatusTracker.shared.startTracking()
        locationSharing.start(interval: 10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "kAgreeTermsOfUse") != true {
            let spamView = NonSpamView.loadFromNib()
            spamView.didCloseSpamView = { [weak self] in
                self?.showEdit()
            }
            spamView.show()
        }
    }
    
    func showEdit() {
        if ARUser.currentUser?.isUpdated == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                let vc = EditVC.instantiate(from: .Profile)
                vc.viewModel = FirstUpdateProfileViewModel(with: ARUser.currentUser!)
                self?.present(vc, animated: true, completion: nil)
            }
        }
        
    }
}

extension HomeTabBarVC: HomeTabBarDelegate {
    
    func didSelect(item: HomeTabBarItem, index: Int, tabBar: HomeTabBar) {
        selectedIndex = index
        if let arrayVC = viewControllers {
            selectedViewController = arrayVC[index]
        }
    }
    
}

