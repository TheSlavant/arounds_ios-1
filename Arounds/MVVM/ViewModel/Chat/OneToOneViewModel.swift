//
//  OneToOneViewModel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

final class OneToOneViewModel: BaseChatViewModel {
    
    private var isConversationExistObserverId: DatabaseHandle?
    
    override init(chat: ARChat) {
        super.init(chat: chat)
        
        //checkIfConversationExist()
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
