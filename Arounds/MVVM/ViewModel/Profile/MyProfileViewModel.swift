//
//  MyProfileViewModel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import Foundation

class MyProfileViewModel: ProfileViewModeling {
    
    var didFetchedBlock: ((ARProfileBlock?) -> Void)?
    var userBlock: ARProfileBlock?
    
    var user: ARUser?
    var social: ARSocial?
    var didFetchedSocial: ((ARSocial?) -> Void)?

    var isILike: Bool! = false

    required init(with newUser: ARUser) {
        user = newUser
        guard let userID = user?.id else {return}
        Database.Users.social(userID: userID) { [weak self] (social) in
            if social != nil {
                social?.save()
            }
            self?.social = social
            self?.didFetchedSocial?(social)
        }
        
        Database.ProfileBlock.userBlock(by: userID) { [weak self] (block) in
            self?.userBlock = block
            self?.didFetchedBlock?(block)
        }
    }
    
    func likes(handler: (([String : Any]) -> Void)?) {
        Database.Likes.likes(userID: user?.id ?? "") {(likes) in
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
