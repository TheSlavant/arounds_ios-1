//
//  RadarMessage.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class RadarMessage {
    var id: String
    var text: String!
    var date: Date!
    var senderID: String!
    var blockers: [String]!
    var senderAvatar: String!
    var senderDisplyName: String!
    
    init(with dict: [String: Any], messageID: String) {
        id = messageID
        date = Date(timeIntervalSince1970: (dict["timestamp"] as? Double ?? 0) / 1000)
        text = dict["text"] as? String ?? ""
        senderID = dict["senderID"] as? String ?? ""
        blockers = dict["blockers"] as? [String] ?? [String]()
    }
}
