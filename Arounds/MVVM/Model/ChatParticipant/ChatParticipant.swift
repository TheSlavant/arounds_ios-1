//
//  ChatParticipant.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

struct ChatParticipant: Equatable {
    
    let id: String
    let nickName: String
    let firstName: String
    let lastName: String
    let isMe: Bool
    
    init(id: String, nickName: String, firstName: String, lastName: String, isMe: Bool) {
        self.id = id
        self.nickName = nickName
        self.firstName = firstName
        self.lastName = lastName

        self.isMe = isMe
        
        assert(!id.isEmpty)
        assert(!nickName.isEmpty)
        assert(!firstName.isEmpty)
        assert(!lastName.isEmpty)

    }
    
    static func ==(lhs: ChatParticipant, rhs: ChatParticipant) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ARUser {
    func toParticipant() -> ChatParticipant? {
        guard let userId = self.id, let first = self.firstName, let last = self.lastName, let nick = self.nickName else { return nil}
        return  ChatParticipant.init(id: userId,
                                     nickName: nick,
                                     firstName: first,
                                     lastName: last,
                                     isMe: userId == ARUser.currentUser?.id ?? "")
    }
}



