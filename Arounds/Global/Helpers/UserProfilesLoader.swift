//
//  UserProfilesLoader.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/7/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase


final class UserProfilesLoader {
    
    class func loadUser(userID: String, completion handler:((ARUser?)->Void)?) {
        Database.Users.user(userID: userID) { (user) in
            handler?(user)
        }
    }
}
