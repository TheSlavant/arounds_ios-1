//
//  ChatMessage.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class ChatMessage {
    var messageId: String = ""
    var senderDisplayName: String = ""
    var senderId: String = ""
    var body: String = ""
    var timestamp: [String: String]? = [:]
    var time: Double?
    var url: String?
    var type: String? // ChatMessageType
    var readTime: Double?
    var image: UIImage?
    var decrypted: Bool = false
    var voiceData: Data?
    var readCount: Int = 0
    var deliveredCount: Int = 0
    var decryptDataString: String!
    var readBy: [String: Bool] = [:]
    var status: String = ""
    
    var typeEnum: ChatMessageType? {
        set {
            type = newValue?.rawValue
        }
        get {
            guard let type = type else {
                return nil
            }
            
            return ChatMessageType(rawValue: type)
        }
    }
    
    init() {}

    init(chatMessage: ChatMessage) {
        messageId = chatMessage.messageId
        senderId = chatMessage.senderId
        body = chatMessage.body
        timestamp = chatMessage.timestamp
        time = chatMessage.time
        url = chatMessage.url
        type = chatMessage.type
        readTime = chatMessage.readTime
        image = chatMessage.image
        decrypted = chatMessage.decrypted
        voiceData = chatMessage.voiceData
        readCount = chatMessage.readCount
        deliveredCount = chatMessage.deliveredCount
        readBy = chatMessage.readBy
        status = chatMessage.status
        senderDisplayName = chatMessage.senderDisplayName
    }

    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        
        dictToItem(dictionary)
    }
    
    func dictToItem(_ dict: [String: AnyObject]) {
        self.decrypted = false
        
        var index = dict.index(forKey: "sender")
        if(index != nil) {
            senderId = dict.values[index!] as! String
        }
        index = dict.index(forKey: "messageId")
        if(index != nil) {
            messageId = dict.values[index!] as! String
        }
        index = dict.index(forKey: "text")
        if(index != nil) {
            body = dict.values[index!] as! String
        }
        index = dict.index(forKey: "timestamp")
        if(index != nil) {
            time = dict.values[index!] as? Double
        }
        index = dict.index(forKey: "type")
        if(index != nil) {
            type = dict.values[index!] as? String
        }
        index = dict.index(forKey: "url")
        if(index != nil) {
            url = dict.values[index!] as? String
        }
        index = dict.index(forKey: "readTime")
        if(index != nil) {
            readTime = dict.values[index!] as? Double
        } else {
            readTime = 0
        }
      
        index = dict.index(forKey: "senderDisplayName")
        if(index != nil) {
            senderDisplayName = dict.values[index!] as! String
        }

        index = dict.index(forKey: "readCount")
        if(index != nil) {
            readCount = dict.values[index!] as! Int
        } else {
            readCount = 0
        }
        
        index = dict.index(forKey: "deliveredCount")
        if(index != nil) {
            deliveredCount = dict.values[index!] as! Int
        } else {
            deliveredCount = 0
        }
        
        index = dict.index(forKey: "readBy")
        if(index != nil) {
            readBy = dict.values[index!] as! [String: AnyObject] as! [String: Bool]
        }
        
        self.status = dict["status"] as? String ?? ""
        
        image = nil
        voiceData = nil
    }

    func itemToDict() -> NSDictionary {
        let displayName = ARUser.currentUser?.id == senderId ? ARUser.currentUser?.nickName ?? "" : senderDisplayName
        let dict: [String: AnyObject] = ["messageId" : messageId as AnyObject,
                                         "sender" : senderId as AnyObject,
                                         "text": body as AnyObject,
                                         "timestamp": timestamp as AnyObject,
                                         "type": type as AnyObject,
                                         "url": (url ?? "") as AnyObject ,
                                         "status": self.status as AnyObject,
                                         "senderDisplayName": displayName as AnyObject]
        
        return dict as NSDictionary
    }

}
