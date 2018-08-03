//
//  FirebaseMethods.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/28/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase
import Foundation

class FirebaseMethods {
    static let sharedInstance = FirebaseMethods()
    private init() {}

    // MARK: USER IS TYPING STATUS UPDATE
    func userIsTyping(chatRoom: String, value: Bool , userName: String = ARUser.currentUser?.nickName ?? "") {
        let username = userName
        let typingRef = Database.database().reference().child("user-typing").child(chatRoom).child(username)
        if(value) {
            typingRef.setValue(value)
        } else {
            typingRef.removeValue()
        }
        
    }

}
