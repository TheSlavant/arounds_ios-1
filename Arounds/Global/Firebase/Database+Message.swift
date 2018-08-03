//
//  Database+Message.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/7/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

fileprivate let kChat_rooms = "chat-rooms"

extension Database {
    
    enum Message: DatabaseAccess {
        
        static func createEmpty(for participantID: String, in chat: ARChat) -> String {
            return createEmpty(for: participantID, in: chat.id)
        }
        
        static func createEmpty(for participantID: String, in chatId: String) -> String {
            return database.child(kChat_rooms).child(chatId).child("users").child(participantID).child("chats").childByAutoId().key
        }
        
        //
        static func send(_ message: ChatMessage, participantID: String, chat: ARChat) {
            send(message, participantID: participantID, chatId: chat.id)
        }
        
        static func send(_ message: ChatMessage, participantID: String, chatId: String) {
            
            let newChatMsg = database.child("chat-rooms").child(chatId).child("users").child(participantID).child("chats").child(message.messageId)
            
            newChatMsg.setValue(message.itemToDict()) { (error, database) in
            }
            
        }
        
        static func updateAttachmentUrl(_ messageId: String, participantID: String, chat: ARChat, url: String) {
            let message = database.child("chat-rooms").child(chat.id).child("users").child(participantID).child("chats").child(messageId).child("url")
            message.setValue(url)
        }
        
        static func remove(_ messageID: String, participantID: String, chat: ARChat) {
            database.child("chat-rooms")
                .child(chat.id)
                .child("users")
                .child(participantID)
                .child("chats")
                .child(messageID).removeValue { (_, _) in
            }
            
        }
        
        static func markAsSeen(_ message: JSQMessage, with id: String, chat: ARChat) {
            DispatchQueue.global().async {
                if (message.isIncomming && message.status != .seen) {
                    if message.type != .typing {
                        sampleMarkAsSeen(message, with: id, chat: chat)
                    }
                }
                
            }
            //            DispatchQueue.main.async {
            //            }
        }
        
        static func sampleMarkAsSeen(_ message: JSQMessage, with id: String, chat: ARChat) {
            for participant in chat.participans {
                let messageRef = self.database.child("chat-rooms").child(chat.id).child("users").child(participant).child("chats").child(id)
                messageRef.child("status").setValue(ChatMessageStatus.seen.rawValue)
                messageRef.child("readTime").setValue([".sv":"timestamp"])
            }
            
            //                Database.Inbox.markAsSeen(in: chat)
        }
        
        
    }
}

