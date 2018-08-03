//
//  Database+Chat.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

fileprivate let kChat_rooms = "chat-rooms"

extension Database {
    
    enum Chat: DatabaseAccess {
        //chat room
        
        static func getChat(chatID: String, callback: @escaping ((ARChat?) -> Void)) {
            
            database.child(kChat_rooms).child(chatID).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(), let dict = snapshot.value as? [String: Any] {
                    callback(ARChat(with: dict, chatID: chatID))
                    return
                }
                callback(nil)

            }
            
        }
        
        static func getChat(reciverID: String, callback: @escaping ((ARChat?, Error?) -> Void)) {
            guard let myID = ARUser.currentUser?.id else { return }
            
            database.child(kChat_rooms).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let postDict = snapshot.value as? [String : [String: Any]] ?? [:]
                let chats = postDict.filter({ (obj) -> Bool in
                    if let users = obj.value["users"] as? [String:Any] {
                        return users.keys.contains(reciverID) && users.keys.contains(myID)
                    }
                    return false
                })
                if chats.count > 0, let chatDict = chats.first {
                    callback(ARChat(with: chatDict),nil)
                    return
                } else {
                    Database.Chat.empotyChatRoom(reciverID: reciverID, callback: { (_) in
                        Database.Chat.getChat(reciverID: reciverID, callback: { (chat, error) in
                            callback(chat,error)
                        })
                    })
                }
            }, withCancel: { (error) in
                callback(nil,error)
                
            })
            callback(nil,nil)
        }
        //create an empoty chat room
        
        static func empotyChatRoom(reciverID: String, callback: @escaping ((String) -> Void)) {
            guard let myID = ARUser.currentUser?.id else { return }
            
            let newRoomID = database.child(kChat_rooms).childByAutoId().key
            database.child(kChat_rooms).child(newRoomID).setValue(["owner" : myID,
                                                                   "users" : [myID : ["chats": [" ":" "]], reciverID : ["chats" : [" ":" "]]],
                                                                   "accepted" : [myID:false, reciverID:false]])
            _ = Database.ChatAccept.create(by: newRoomID, participantsID: [ARUser.currentUser?.id ?? "", reciverID])
            callback(newRoomID)
        }
        
        static func chatsWithMe(callback: @escaping (([ARChat]) -> Void)) {
            guard let myID = ARUser.currentUser?.id else { return }
            
            let newRoomID = database.child(kChat_rooms).childByAutoId().key
            
//            database.child(kChat_rooms).child(newRoomID).setValue(["owner" : myID,
//                                                                   "users" : [myID : ["chats": [" ":" "]], reciverID : ["chats" : [" ":" "]]],
//                                                                   "accepted" : [myID:false, reciverID:false]])
//            _ = Database.ChatAccept.create(by: newRoomID, participantsID: [ARUser.currentUser?.id ?? "", reciverID])
//            callback(newRoomID)
        }

    }
    
    
}

