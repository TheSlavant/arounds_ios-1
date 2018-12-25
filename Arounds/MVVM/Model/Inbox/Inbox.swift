//
//  Inbox.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/13/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class ARInbox {
    var id: String!
    var chatID: String!
    var senderID: String!
    var senderAvatar: String!   //URL
    var displayName: String!
    var participans: [String]!
    var text: String?
    var type: ChatMessageType!
    var date: Date!
    var seen: Bool = true
    var reciverAvatar: String!
    var reciverName: String!
    
    init(with dict:[String: Any], inboxId: String) {
        id = inboxId
        chatID = dict["chatID"] as? String ?? ""
        senderID = dict["senderID"] as? String ?? ""
        displayName = dict["displayName"] as? String ?? ""
        participans = dict["participans"] as? [String] ?? [String]()
        text = dict["text"] as? String
        type = ChatMessageType.init(rawValue: (dict["type"] as? String) ?? "text")
        date = Date.init(timeIntervalSince1970: (dict["timestamp"] as? Double) ?? 0)
        seen = dict["seen"] as? Bool ?? true
        senderAvatar = dict["senderAvatar"] as? String ?? ""
        reciverAvatar = dict["reciverAvatar"] as? String ?? ""
        reciverName = dict["reciverName"] as? String ?? ""

    }
    
    func getImage() -> UIImage? {
        
        if let base64 = senderAvatar, let data = Data.init(base64Encoded: base64, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func reciverImage() -> UIImage? {
        if let base64 = reciverAvatar, let data = Data.init(base64Encoded: base64, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func reciverImageURL() -> URL? {
        if let base64 = reciverAvatar, let url = URL.init(string: base64) {
            return url
        }
        return nil
    }

    
    func senderImageURL() -> URL? {
        if let url = senderAvatar, url.hasPrefix("https") {
            return URL.init(string: url)
        }
        return nil
    }

    

}
