//
//  ChatMessage+Create.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/7/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension ChatMessage {
    
    static func createMessage(id: String,
                              text: String = "",
                              url: String = "",
                              type: ChatMessageType,
                              for chat: ARChat,
                              status: ChatMessageStatus = .failed) -> ChatMessage {
        
        return ChatMessage.createMessage(id: id, text: text, url: url, type: type, senderId: chat.me, status: status)
    }
    
    static func createMessage(id: String,
                              text: String = "",
                              url: String = "",
                              type: ChatMessageType,
                              senderId: String,
                              status: ChatMessageStatus = .failed) -> ChatMessage {
        let message = ChatMessage()
        
        message.messageId = id
        message.body = text
        message.url = url
        message.senderId = senderId
        message.type = type.rawValue
        message.status = status.rawValue
        message.timestamp = [".sv":"timestamp"]
        message.time = Date().timeIntervalSince1970 * 1000
        
        return message
    }
}

