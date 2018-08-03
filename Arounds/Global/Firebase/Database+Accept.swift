//
//  Database+Accept.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/12/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

fileprivate let kChat_accept = "chat-accept"

extension Database {
    
    enum ChatAccept: DatabaseAccess {
        
        static func create(by chatID: String, participantsID:[String]) -> String {
            
            let acceptID = database.child(kChat_accept).childByAutoId().key
            assert(participantsID.count > 1)
            
            let user1 = participantsID[0]
            let user2 = participantsID[1]
            
            var status = [String: Int]()
            status[user1] = 3
            status[user2] = 3
            
            database.child(kChat_accept).child(acceptID).setValue(["chatID":chatID,
                                                                   "status":status])
            return acceptID
        }
        
        static func accepted(by chatID: String, completion handler:((ARChatAccept?)->Void)?) {
            let ref = database.child(kChat_accept).queryOrdered(byChild: "chatID").queryEqual(toValue: chatID)
            ref.observe(.value) { (snapshot) in
                if snapshot.exists() {
                    if let dict = snapshot.value as? [String:[String:Any]] {
                        let accepet = ARChatAccept(dict: dict)
                        handler?(accepet)
                        return
                    }
                }
                handler?(nil)

            }
                    
        }
        
        static func change(status accept:AcceptType, acceptID: String) {
           database.child(kChat_accept).child(acceptID).child("status").child(ARUser.currentUser?.id ?? "").setValue(accept.rawValue)
        }
        
    }
    
    
}
