//
//  Database+UserTyping.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/28/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

extension Database {
    
    enum UserTyping: DatabaseAccess {
        
        static func enable(in chat: ARChat, isTyping: Bool) {
            let typingRef = database.child("user-typing").child(chat.id).child(ARUser.currentUser?.id ?? "")
            if isTyping {
                typingRef.removeValue()
                typingRef.setValue(true)
            } else {
                typingRef.removeValue()
            }
        }
        
    }
    
}
