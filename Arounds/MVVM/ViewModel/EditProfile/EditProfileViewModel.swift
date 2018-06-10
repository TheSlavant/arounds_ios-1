//
//  EditProfileViewModel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import Foundation

class EditProfileViewModel: EditProfileViewModeling {
    
    var didFetchedSocial: ((ARSocial?) -> Void)?
    var didClick: ((ARButton) -> Void)?
    var user: ARUser?
    var social: ARSocial?
    
    var isHiddendBackButton: Bool
    
    required init(with newUser: ARUser) {
        user = newUser
        isHiddendBackButton = false
        Database.Users.social(userID: user?.id ?? "") { [weak self] (social) in
            self?.social = social
            self?.didFetchedSocial?(social)
        }
    }
    
    func validate(fields fireID: String,
                  fullName: String,
                  nicName: String,
                  gender: UserGender,
                  date: Date?,
                  aboute: String,
                  avatar: String,
                  phone: String,
                  completion handler: ((String?, ARUpdateUserBuilder?) -> Void)?) {
        
        let result = ARValidation.validateUpdated(fields: fireID,
                                                  fullName: fullName,
                                                  nicName: nicName,
                                                  gender: gender,
                                                  date: date,
                                                  aboute: aboute,
                                                  avatar: avatar,
                                                  phone: phone)
        
        handler?(result.0, result.1)
    }
    
    func update(user builder:ARUpdateUserBuilder, completion handler:((Error? , Bool?)->Void)?) {
        ProfileApi().update(user: builder) { (error, success) in
            handler?(error, success)
        }
    }
    
    func updateSocial() {
        if let social = social {
            Database.Users.setSocial(social: social, userID: user?.id ?? "")
        }
    }

    
    
}
