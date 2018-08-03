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
    var userBlock: ARProfileBlock?
    var didFetchedBlock: ((ARProfileBlock?) -> Void)?

    required init(with newUser: ARUser) {
        user = newUser
        guard let userID = user?.id else {return}
        Database.Users.social(userID: userID) { [weak self] (social) in
            self?.social = social
            self?.didFetchedSocial?(social)
        }
        
        Database.ProfileBlock.userBlock(by: userID) { [weak self] (block) in
            self?.userBlock = block
            self?.didFetchedBlock?(block)
        }
    }
    
    func likes(handler: (([String : Any]) -> Void)?) {
        Database.Likes.likes(userID: user?.id ?? "") { [weak self] (likes) in
            self?.isILike = likes.keys.contains(ARUser.currentUser?.id ?? "")
            handler?(likes)
        }
    }
    
    func startFatchingSocial() {
        guard let userID = user?.id else {return}
        Database.Users.social(userID: userID) { [weak self] (social) in
            if social != nil {
                social?.save()
            }
            self?.social = social
            self?.didFetchedSocial?(social)
        }
    }

    
}
