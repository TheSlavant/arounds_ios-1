//
//  Chat+Create.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

// MARK: - Create One to One
extension ARChat {

    static func createOneToOne(receiverId: String) -> ARChat? {
        guard (ARUser.currentUser?.id) != nil else {return nil}
        

        return nil
    }
    
//    static func createOneToOne(receiverId: String) -> Chat? {
//        guard let myID = ARUser.currentUser?.id else {return nil}
//
//
//    }

}
