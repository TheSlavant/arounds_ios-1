//
//  PushNotification.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/7/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation
import Just
import FirebaseDatabase

class PushNotification {
    static let sharedInstance = PushNotification()
    var json: [String: Any]! = nil
    
    private init() {}
    
    func sendMessagePush(to chat: ARChat, reciverToken: String, body: String) {
        for participantID in chat.participans where !participantID.isMe() {
            
            PushNotification.sharedInstance.sendMessagePush(chatRoomId: chat.id,
                                                            userId: participantID,
                                                            username: ARUser.currentUser?.nickName ?? "",
                                                            type: chat.type == .oneToOne ? 1 : 2,
                                                            handler: "",
                                                            sound: NotificationRingTone.default.filename,
                                                            reciverToken: reciverToken,
                                                            body: body)
        }
    }
    
    private func sendMessagePush(chatRoomId: String, userId: String, username: String, type: Int, handler: String, sound: String, reciverToken: String, body: String, title: String = "") {
        let getBadge = Database.database().reference().child("badge").child(userId)
        getBadge.keepSynced(true)
        
        getBadge.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            var badge = currentData.value as? Int
            
            if(badge == nil) {
                badge = 1
            } else {
                badge = badge! + 1
            }
            
            currentData.value = badge
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if(error == nil && committed == true) {
                let badge = snapshot?.value as! Int
                
                self.sendNotificationWithBadge(chatRoomId: chatRoomId,
                                               username: username,
                                               type: type,
                                               handler: handler,
                                               badge: badge,
                                               sound: sound,
                                               reciverToken: reciverToken,
                                               body: body,
                                               title: title)
            }
        }
    }
    
    func sendNotificationWithBadge(chatRoomId: String = "", username: String = "", type: Int = 1, handler: String = "", badge: Int = 0, sound: String = NotificationRingTone.default.filename, reciverToken: String, body: String, title: String) {
        if(type == 1) {
            //simple message
            json = makeJSON(sound: sound, DCS: reciverToken, chatRoomID: chatRoomId, body: body, title: title)
        } else {
            //group message
            //            json = makeJSONGroupPush(chatRoomId: chatRoomId, user: username, handler: handler, badge: badge, sound: sound)
        }
        
        let headers = ["Content-Type": "application/json", "Authorization": "key=AAAAO8hbih4:APA91bGOKf9DUlHqGV091ez9_uHWaHy5FvHdbZKnLbg446abPRML7OadEKdZjAQ0lnTRA7A0OewVbLh8FT8foGS9CTQH9LjY5KL96x_nLFy2t4QVHeRFDZkUt7ueq4HkxmectsML-jJH55xMI4WACgpmSPdTaQAaDA"]
        
        
        Just.post(notificationURL, json: json, headers: headers) {
            (r) in
            if(r.ok) {
                print(r.description)
                //do nothing
                print("Success")
            } else {
                print(r.error?.localizedDescription)
            }
        }
    }
    
    private func makeJSONGroupPush(chatRoomId: String, user: String, handler: String, badge: Int, sound: String) -> [String: Any] {
        let topicTo = "/topics/\(user)"
        
        let uid = ARUser.currentUser?.fullName ?? ""
        let notificationDict = ["body":"\(uid) sent you a message in \(handler)", "alert" : "message",
                                "sound" : sound,
                                "messageContent":"\(uid) has sent you a message in \(handler)",
            "chatRoomId":chatRoomId, "badge": badge] as [String: Any]
        
        _ = [ "alert" : "message",
              "sound" : sound]
        
        
        
        let finalDict = ["to": topicTo, "notification": notificationDict, "chatRoomId":chatRoomId] as [String: Any]
        
        _ = JSONSerialization.isValidJSONObject(finalDict)
        
        return finalDict
    }
    
    private func makeJSON(sound: String, DCS: String, chatRoomID: String, body: String, title: String = "") -> [String: Any] {
        //        let topicTo = "\(DCS))"
        //
        //        let uid = ARUser.currentUser?.nickName ?? ""
        //
        //        let notificationDict = ["body":"\(uid) sent you a message", "alert" : "message",
        //                                "sound" : sound,
        //                                "messageContent":"\(uid) sent you a message",
        //            "chatRoomId":chatRoomId, "badge": badge] as [String: Any]
        //
        //        _ = [ "alert" : "message",
        //              "sound" : sound]
        //
        //        let finalDict = ["to": topicTo, "notification": notificationDict, "chatRoomId":chatRoomId] as [String: Any]
        //
        //        _ = JSONSerialization.isValidJSONObject(finalDict)
        
        return ["content_available":true,
                "sounds": sound,
                "notification":["body":body,"title":title],
                "to": DCS,
                "data": [ "chatRoomID": chatRoomID,
                          "senderID":ARUser.currentUser?.id ?? ""]]
        
        
        //     return finalDict
    }
    
}
