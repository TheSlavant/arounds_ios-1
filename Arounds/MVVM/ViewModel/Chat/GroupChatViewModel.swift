//
//  GroupChatViewModel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

final class GroupChatViewModel: BaseChatViewModel {
    
    private var isConversationExistObserverId: DatabaseHandle?
    
    override init(chat: ARChat) {
        super.init(chat: chat)
        
        checkIfConversationExist()
    }
    
    private func checkIfConversationExist() {
        self.isConversationExistObserverId = Database.Inbox.subscribeIfExists(inboxId: self.chat.id, userId: self.chat.owner) { [weak self] isExist in
            self?.isChatActive = isExist
        }
    }
    
    deinit {
        if let isConversationExistObserverId = isConversationExistObserverId {
            self.database.removeObserver(withHandle: isConversationExistObserverId)
        }
    }
}
