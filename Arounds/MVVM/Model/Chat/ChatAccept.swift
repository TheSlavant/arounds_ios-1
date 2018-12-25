//
//  ChatAccept.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/12/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

enum AcceptType: Int {
    case panding = 3
    case accepted = 1
    case reject = 2
}

struct UserAccept {
    let userID: String!
    var accept: AcceptType!
}

class ARChatAccept {
    var id: String!
    
    let chatID:String!
    var myAccept: UserAccept?
    var reciverAccept: UserAccept?

    
    init(dict: [String:[String:Any]]) {
        let key = dict.keys.first ?? ""
        let values = dict[key]
        id = key
        chatID = values?["chatID"] as? String
        
        if let status = values?["status"] as? [String: Int] {
            for obj in status {
                if obj.key == ARUser.currentUser?.id {
                    myAccept = UserAccept(userID: obj.key, accept: AcceptType(rawValue: obj.value))
                } else {
                    reciverAccept = UserAccept(userID: obj.key, accept: AcceptType(rawValue: obj.value))
                }
            }
        }
        
    }
}
