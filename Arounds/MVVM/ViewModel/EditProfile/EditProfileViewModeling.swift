//
//  EditProfileViewModeling.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation


protocol EditProfileViewModeling {
    init(with newUser: ARUser)
    var user: ARUser? { get set }
    var social: ARSocial? { get set }
    var didFetchedSocial: ((ARSocial?) -> Void)? { get set }

    var isHiddendBackButton: Bool { get set }
  
    func updateSocial()
    func update(user builder:ARUpdateUserBuilder, completion handler:((Error? , Bool?)->Void)?)
    func validate(fields fireID: String,
                  fullName:String,
                  nicName:String,
                  gender:UserGender,
                  date:Date?,
                  aboute:String,
                  avatar:String,
                  phone:String,
                  completion handler:((String? , ARUpdateUserBuilder?)->Void)?)
}
