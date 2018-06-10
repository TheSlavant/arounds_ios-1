//
//  OtherProfileViewModel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase
import Foundation

class OtherProfileViewModel: ProfileViewModeling {
    var didFetchedSocial: ((ARSocial?) -> Void)?
    var likes: (([String : Any]) -> Void)?
    var user: ARUser?
    var social: ARSocial?
    var isILike: Bool! = false
    
    required init(with newUser: ARUser) {
        user = newUser
        Database.Users.social(userID: user?.id ?? "") { [weak self] (social) in
            self?.social = social
            self?.didFetchedSocial?(social)
        }
    }
    
    func likes(handler: (([String : Any]) -> Void)?) {
        Database.Likes.likes(userID: user?.id ?? "") { [weak self] (likes) in
            self?.isILike = likes.keys.contains(ARUser.currentUser?.id ?? "")
            handler?(likes)
        }
    }
    
}
