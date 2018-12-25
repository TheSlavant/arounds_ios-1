//
//  Database+Inbox.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

let kUser_inbox = "user-inbox"

extension Database {
    
    enum Inbox: DatabaseAccess {
        
        static func subscribeIfExists(inboxId: String, userId: String, callback: @escaping ((Bool) -> Void)) -> DatabaseHandle {
            return database.child(kUser_inbox).child(userId).child(inboxId).observe( .value, with: { (snapshot) in
                callback(snapshot.exists())
            })
        }
        
        static func update(chat: ARChat, sender: ARUser, reciver: ARUser, message: JSQMessage) {
            if message.type == .typing {return}
            inbox(by: chat.id) { (inbox) in
                
                let dict = ["chatID" : chat.id,
                            "text" : message.text ?? "",
                            "type": message.type.rawValue,
                            "senderID" : message.senderId,
                            "displayName":sender.nickName ?? "",
                            "timestamp": [".sv":"timestamp"],
                            "participans": chat.participans,
                            "seen": false,
                            "senderAvatar": sender.avatarBase64 ?? "",
                            "reciverAvatar": reciver.avatarBase64 ?? "",
                            "reciverName":reciver.nickName ?? ""] as [String : Any]
                
                database.child("allMSG").childByAutoId().updateChildValues(dict)
                database.child(kUser_inbox).child(inbox?.id ?? "").setValue(dict)
            }
        }
        
        static func update(chat: ARChat, sender: ARUser, type: ChatMessageType, reciver: ARUser) {
            inbox(by: chat.id) { (inbox) in
                
                if type != .typing {
                    database.child(kUser_inbox).child(inbox?.id ?? "").updateChildValues(["seen": false,
                                                                                          "type": chat.id,
                                                                                          "chatID": chat.id,
                                                                                          "senderID": ARUser.currentUser?.id ?? "",
                                                                                          "timestamp": [".sv":"timestamp"],
                                                                                          "participans": chat.participans,
                                                                                          "senderAvatar": sender.avatarBase64 ?? "",
                                                                                          "reciverAvatar": reciver.avatarBase64 ?? "",
                                                                                          "reciverName":reciver.nickName ?? ""])
                }
            }
        }
        
        
        static func inbox(by chatID: String, callback: @escaping ((ARInbox?) -> Void)) {
            let ref = database.child(kUser_inbox)
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(), let value = snapshot.value as? [String: [String: Any]] {
                    
                    if let dict = value.filter({(($0.value["chatID"] as? String) == chatID)}).first {
                        callback(ARInbox(with: dict.value, inboxId: dict.key))
                        return
                    }
                    
                }
                _ = empotyInbox(by: chatID)
                inbox(by: chatID, callback: { (inbox) in
                    callback(inbox)
                })
            }
        }
        
        static func empotyInbox(by chatID: String) -> String {
            let ref = database.child(kUser_inbox)
            let newInboxID = ref.childByAutoId().key
            ref.child(newInboxID).setValue(["chatID" : chatID])
            return newInboxID
        }
        
        static func inboxes(callback: @escaping (([ARInbox]) -> Void)) {
            let ref = database.child(kUser_inbox)
            
            ref.observe(.value) { (snapshot) in
                if snapshot.exists(), let value = snapshot.value as? [String: [String: Any]] {
                    let dict = value.filter({(($0.value["participans"] as? [String])?.contains(ARUser.currentUser?.id ?? "")) ?? false})
                    callback(dict.map({ARInbox(with: $0.value, inboxId: $0.key)}))
                    return
                }
                callback([ARInbox]())
            }
        }
        
        static func markAsSeen(chatID: ARChat) {
            
        }
        
        static func updateMyAvatarFromInboxes(url: String, callback: @escaping (() -> Void)) {
            
            Inbox.inboxes { (inboxes) in
                let ref = database.child(kUser_inbox)
                inboxes.forEach({ (inbox) in
                    if inbox.senderID == ARUser.currentUser?.id ?? "" {
                        ref.child(inbox.id).updateChildValues(["senderAvatar" : url])
                    } else {
                        ref.child(inbox.id).updateChildValues(["reciverAvatar" : url])
                    }
                })
                callback()
            }
        }
    }
    
}
