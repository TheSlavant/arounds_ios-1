//
//  ChatMessage+JSQMessage.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import JSQMessagesViewController.JSQMessage

extension ChatMessage {
    
    var jsqMessage: JSQMessage? {
        let senderId = self.senderId
        var senderUsername = senderDisplayName

        if senderId == ARUser.currentUser?.id ?? "" {
            senderUsername = ARUser.currentUser?.nickName ?? ""
        }
                
        guard !senderId.isEmpty,
            let time = time,
            let type = ChatMessageType(rawValue: type ?? "") else {
                return nil
        }
        
        let date = Date(timeIntervalSince1970: time/1000)
        
        var message: JSQMessage?
        
        switch type {
        case .text, .typing:
            guard !self.body.isEmpty else {
                return nil
            }
            
            message = JSQMessage(senderId: senderId,
                                 senderDisplayName: senderUsername,
                                 date: date,
                                 text: body)
        case .image, .voice:
            guard let stringUrl = self.url,
                let url = URL(string: stringUrl) else {
                    return nil
            }
            
            let media = AttachmentMessageMediaData()
            message = JSQMessage(senderId: senderId,
                                 senderDisplayName: senderUsername,
                                 date: date,
                                 media: media)
            message?.attachmentURL = url
            
            media.message = message
        }
        
        message?.type = type
        message?.status = ChatMessageStatus(rawValue: self.status) ?? .sent
        message?.isIncomming = message?.senderId != ARUser.currentUser?.id ?? ""
        
        return message
    }
    
}

