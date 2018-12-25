//
//  Chat.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

enum ChatType {
    case oneToOne
    case group
}

struct ARChat: Equatable {
    let id: String
    let participans: [String] // participans ids
    let owner: String // owner id
    let me: String = ARUser.currentUser?.id ?? "" // my id
    let type: ChatType
    var accepted: [String:Bool]?

    
    init(id: String, participans: [String], type: ChatType, ownerID: String) {
        self.id = id
        self.participans = participans
        self.type = type
        self.owner = ownerID
    }

    static func ==(lhs: ARChat, rhs: ARChat) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type && lhs.participans == rhs.participans
    }
    
    init(with dict: (key: String, value: [String : Any])) {
        self.id = dict.key
        self.type = .oneToOne
        self.accepted = dict.value["accepted"] as? [String:Bool]
        self.owner = dict.value["owner"] as? String ?? ""
        let users = dict.value["users"] as! [String : Any]
        self.participans = users.map({$0.key})
    }
    
    init(with dict: [String : Any], chatID: String) {
        id = chatID
        self.type = .oneToOne
        self.accepted = dict["accepted"] as? [String:Bool]
        self.owner = dict["owner"] as? String ?? ""
        let users = dict["users"] as! [String : Any]
        self.participans = users.map({$0.key})
    }

    
    
}




