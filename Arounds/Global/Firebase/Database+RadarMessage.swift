//
//  Database+RadarMessage.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

let kRadar_messages = "radar_messages"
let kRadar_inbox = "radar_inbox"

extension Database {
    
    enum RadarMessage: DatabaseAccess {
        
        static func send(senderID: String, participents: [String], text: String) {
            var participentsID = participents
            database.keepSynced(true)
            let messageRef = database.child(kRadar_messages).childByAutoId()
            messageRef.updateChildValues(["senderID": senderID,"text": text, "timestamp": [".sv":"timestamp"]])
            participentsID.append(ARUser.currentUser?.id ?? "")
            for participent in participentsID {
                database.child(kRadar_inbox).child(participent).observeSingleEvent(of: .value) { (snapshot) in
                    
                    var messages = [String]()
                    if let  dict = snapshot.value as? [String: Any], let mesgs = dict["radarMessages"] as? [String] {
                        messages = mesgs
                    }
                    
                    messages.append(messageRef.key)
                    
                    database.child(kRadar_inbox).updateChildValues([participent : ["radarMessages":messages]])
                }
            }
            FeedBackLogic.shared.radarMessageIsTrue()

        }
        
        static func block(messageID: String, senderID: String, blockers: [String]) {
            
            var a = blockers
            a.append(ARUser.currentUser?.id ?? "")
            
            if a.count == 3 {
                database.child("message_block").child(senderID).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists(), let dict = snapshot.value as? [String: Any] {
                        
                        let blockLavel = (dict["blockLavel"] as? Int ?? 0) + 1
                        
                        if blockLavel == 1 {
                            let date =  Calendar.current.date(byAdding: Calendar.Component.day, value: 3, to: Date())
                            
                            database.child("message_block").child(senderID).updateChildValues(["blockLavel": blockLavel,
                                                                                               "blockStart": [".sv":"timestamp"],
                                                                                               "blockFinish": date?.timeIntervalSince1970 ?? 0])
                        } else if blockLavel == 2 {
                            let date =  Calendar.current.date(byAdding: Calendar.Component.day, value: 14, to: Date())
                            
                            database.child("message_block").child(senderID).updateChildValues(["blockLavel": blockLavel,
                                                                                               "blockStart": [".sv":"timestamp"],
                                                                                               "blockFinish": date?.timeIntervalSince1970 ?? 0])
                        } else {
                            database.child("kRadar_messages").child(senderID).updateChildValues(["blockLavel": blockLavel,
                                                                                                 "blockStart": [".sv":"timestamp"],
                                                                                                 "blockFinish": 0])
                        }
                    } else {
                        let date =  Calendar.current.date(byAdding: Calendar.Component.day, value: 3, to: Date())
                        
                        database.child("message_block").updateChildValues([senderID: ["blockLavel": 1,
                                                                                      "blockStart": [".sv":"timestamp"],
                                                                                      "blockFinish": date?.timeIntervalSince1970 ?? 0]])
                    }
                }
                ////
                database.child(kRadar_messages).child(messageID).removeValue()
                return
            }
            database.child(kRadar_messages).child(messageID).updateChildValues(["blockers":a])
            
        }
        
    }
}


