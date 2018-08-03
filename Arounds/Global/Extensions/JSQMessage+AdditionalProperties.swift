//
//  JSQMessage+AdditionalProperties.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/6/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import JSQMessagesViewController.JSQMessage

extension JSQMessage {
    
    private struct AssociatedKeys {
        static var type = "nsh_Type"
        static var url = "nsh_URL"
        static var isIncomming = "nsh_isIncoming"
        static var status = "nsh_status"
        static var additionalText = "nsh_additionalText"
    }
    
    var type: ChatMessageType {
        get {
            guard let typeString = objc_getAssociatedObject(self, &AssociatedKeys.type) as? String,
                let type = ChatMessageType(rawValue: typeString) else {
                    return .text
            }
            
            return type
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.type,
                newValue.rawValue as NSString?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    
    var status: ChatMessageStatus {
        get {
            guard let typeString = objc_getAssociatedObject(self, &AssociatedKeys.status) as? String,
                let type = ChatMessageStatus(rawValue: typeString) else {
                    return .sent
            }
            
            return type
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.status,
                newValue.rawValue as NSString?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    var additionalText: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.additionalText) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.additionalText,
                newValue as NSString?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    var attachmentURL: URL? {
        get {
            guard let urlString = objc_getAssociatedObject(self, &AssociatedKeys.url) as? String else {
                return nil
            }
            
            return URL(string: urlString)
        }
        set(newValue) {
            let url = newValue?.absoluteString ?? ""
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.url,
                url as NSString?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    var isIncomming: Bool {
        get {
            guard let isIncomming = objc_getAssociatedObject(self, &AssociatedKeys.isIncomming) as? NSNumber else {
                return false
            }
            
            return isIncomming.boolValue
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.isIncomming,
                NSNumber(value:newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
}
