//
//  ProfileViewModeling.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

protocol ProfileViewModeling {
    init(with newUser: ARUser)
    func likes(handler: (([String : Any]) -> Void)?)
   
    var didFetchedSocial: ((ARSocial?) -> Void)? { get set }
    var user: ARUser?  { get set }
    var social: ARSocial? { get set }
    var isILike: Bool! { get set}

}
