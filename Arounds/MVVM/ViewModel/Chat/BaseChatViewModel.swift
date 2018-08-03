//
//  BaseChatViewModel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import SVProgressHUD
import FirebaseStorage
import Firebase
import Foundation
import Kingfisher

protocol BaseChatViewModelDelegate: class {
    
    func didUpdateMessages(_ messages: [JSQMessage], in viewModel: BaseChatViewModel, hasNewMessage: Bool)
    func didUpdateUsersThatAreTyping(_ users: Set<String>, in viewModel: BaseChatViewModel)
    func didUpdateChatAvailability(isChatActive: Bool)
    func didStartPreparingChat()
    func didEndPreparingChat()
    func didFetchedReciver(reciver: ARUser)
    
}

class BaseChatViewModel {
    
    let database = Database.database().reference()
    //
    fileprivate var canPlayIncommingMessageSound = false
    fileprivate var firebaseObserversIds: [UInt] = []
    fileprivate var firebaseUpdateMessagesObserversIds: [String: UInt] = [:]
    fileprivate var fetchAllNewMessagesFirebaseObserversId: UInt?
    fileprivate var fetchAllNewMessagesTimer: Timer?
    //
    var markingNewMesagesAsSeen = false
    fileprivate var typingTimer: Timer?
    
    var didAcceptedFetched:((ARChatAccept?)-> Void)?
    
    //
    weak var delegate: BaseChatViewModelDelegate?
    var me: ARUser? =  ARUser.currentUser
    var recever: ARUser?
    var accepted: ARChatAccept?
    
    var chat: ARChat!
    
    fileprivate(set) var usersTyping: Set<String> = [] {
        didSet {
            self.delegate?.didUpdateUsersThatAreTyping(usersTyping, in: self)
        }
    }
    
    private var userTypindTimer: Timer? {
        didSet {
            if(userTypindTimer == nil && oldValue != nil) {
                Database.UserTyping.enable(in: self.chat, isTyping: false)
                stopTyping()
                
            } else if (userTypindTimer != nil && oldValue == nil) {
                Database.UserTyping.enable(in: self.chat, isTyping: true)
                startTyping()
                
            }
        }
    }
    
    private(set) var messages: [JSQMessage] = [] {
        didSet {
            self.delegate?.didUpdateMessages(messages, in: self,hasNewMessage: oldValue.count != messages.count)
        }
    }
    
    var messagesDictionary: [String: JSQMessage] = [:] {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let messagesDictionary = self?.messagesDictionary else {
                    return
                }
                let messages = Array(messagesDictionary.values)
                
                let typingFiltering = messages.filter({ (message) -> Bool in
                    
                    if message.type == .typing {
                        if message.senderId == ARUser.currentUser?.id ?? "" {
                            return false
                        }
                    }
                    return true
                })
                
                let sortedMessages = typingFiltering.sorted(by: { $0.date < $1.date })
                
                let unseenMessages = sortedMessages.filter({$0.isIncomming == true && $0.status != .seen})
                self?.makeAsSeen(messages: unseenMessages)
                
                messagesDictionary.forEach {
                    self?.subscribeMessageForChangesIfNeeded(key: $0.key, message: $0.value)
                }
                
                DispatchQueue.main.async {
                    self?.messages = sortedMessages
                }
            }
        }
    }
    
    //
    
    var isChatActive: Bool = true {
        didSet {
            delegate?.didUpdateChatAvailability(isChatActive: self.isChatActive)
        }
    }
    
    init(chat: ARChat) {
        self.chat = chat
        
        fetchAccept { [weak self] (newAccepted) in
            self?.accepted = newAccepted
            self?.didAcceptedFetched?(self?.accepted)
        }
        
        Database.Users.user(userID: chat.participans.filter({$0 != me?.id}).first ?? "") {[weak self] (user) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.recever = user
            if let user = user {
                weakSelf.delegate?.didFetchedReciver(reciver: user)
            }
        }
        
    }
    
    func prepare() {
        
        loadMoreMessages { [weak self] in
            guard let sweakSelf = self else {
                return
            }
            
            self?.trackLifecycle()
            self?.enableIncommingMessageSound()
            self?.subscribeForRemovingMessages()
            self?.subscribeForUserTypingStatus(in: sweakSelf.chat)
            
            NotificationCenter.default.addObserver(sweakSelf, selector: #selector(sweakSelf.didDownloadImageAttachment(notification:)), name: NSNotification.Name.KingfisherDidDownloadImage, object: nil)
            
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                sweakSelf.subscribeForNewMessages(toLast: 1)
            }
        }
    }
    
    func chack(callback: @escaping ((Bool,String,Int) -> Void)) {
        let block = ARProfileBlock.rebase()
        
        if (accepted?.reciverAccept?.accept ?? .reject) == .reject || block.blockList.contains(accepted?.reciverAccept?.userID ?? "") {
            callback(false, "Этот пользователь заблокировал вас", 1)
            return
        }
        if (accepted?.myAccept?.accept ?? .reject) == .reject || block.blockListByMe.contains(accepted?.reciverAccept?.userID ?? "") {
            callback(false, "Этот пользователь заблокировал вас", 2)
            return
        }
        callback(true,"",0)
    }
    
    func enableUserTyping() {
        self.userTypindTimer?.invalidate()
        self.userTypindTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] timer in
            self?.userTypindTimer = nil
        }
    }
    
    fileprivate func enableIncommingMessageSound() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.canPlayIncommingMessageSound = true
        }
    }
    
    func removeObservers() {
        self.firebaseUpdateMessagesObserversIds.forEach { self.database.removeObserver(withHandle: $0.value) }
        messagesReference.removeAllObservers()
    }
    
    deinit {
        removeObservers()
    }
    
}

// MARK: - Firebase+MessageStatus
extension BaseChatViewModel {
    
    @objc fileprivate func didDownloadImageAttachment(notification: NSNotification) {
    }
    
    func makeAsSeen(messages: [JSQMessage]) {
        messagesDictionary.forEach { (obj) in
            if messages.contains(obj.value) {
                self.markMessageAsSeen(obj.value, id: obj.key)
            }
        }
        messages.forEach { (message) in
            
        }
    }
    
    func markMessageAsSeen(_ message: JSQMessage, id: String) {
        Database.Message.markAsSeen(message, with: id, chat: chat)
    }
    
}


// Message loading
extension BaseChatViewModel {
    
    func loadNewMessages() {
        let messages = Array(messagesDictionary.values)
        let sortedMessages = messages.sorted(by: { $0.date < $1.date })
        
        guard let date = sortedMessages.last?.date else {
            loadMoreMessages()
            return
        }
        
        loadMessages(from: date)
    }
    
    fileprivate func loadMessages(from date: Date) {
        let query = messagesReference.queryOrdered(byChild: "timestamp").queryStarting(atValue: date.timeIntervalSince1970 * 1000)
        
        query.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            self?.getChatMessages(from: snapshot, callback: { messages in
                let allLoadedMessages = (self?.messagesDictionary ?? [:]) + messages
                self?.messagesDictionary = allLoadedMessages
            })
        })
    }
    
    fileprivate func subscribeForRemovingMessages() {
        let childRemovedId = self.messagesReference.observe(.childRemoved, with: { [weak self] snapshot in
            self?.getChatMessage(from: snapshot, callback: { (message, messageId) in
                self?.messagesDictionary.removeValue(forKey: messageId)
            })
        })
        
        self.firebaseObserversIds.append(childRemovedId)
    }
    
    @discardableResult
    fileprivate func subscribeForNewMessages(toLast last: UInt?) -> DatabaseHandle {
        var query = self.messagesReference.queryOrdered(byChild: "timestamp")
        
        if let last = last {
            query = query.queryLimited(toLast: last)
        }
        
        let childAddedId = query.observe(.childAdded, with: { [weak self] snapshot in
            //            if self?.accepted?.myAccept.accept == .reject {return}
            self?.getChatMessage(from: snapshot, callback: { (message, messageId) in
                if self?.messagesDictionary[messageId] == nil {
                    self?.messagesDictionary[messageId] = message
                    if message.isIncomming && self?.canPlayIncommingMessageSound == true && self?.markingNewMesagesAsSeen == true {
                        ChatSoudEffectsPlayer.shared.play(effect: .receiveMessage)
                    }
                }
            })
        })
        
        self.firebaseObserversIds.append(childAddedId)
        
        return childAddedId
    }
    
    private func getChatMessage(from value: [String: AnyObject], callback: @escaping ((JSQMessage, String) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let message = self?.getChatMessage(from: value) else {
                return
            }
            
            DispatchQueue.main.async {
                callback(message.0, message.1)
            }
        }
    }
    
    
    private func getChatMessage(from snapshot: DataSnapshot, callback: @escaping ((JSQMessage, String) -> Void)) {
        guard let value = snapshot.value as? [String: AnyObject] else {
            return
        }
        getChatMessage(from: value, callback: callback)
    }
    
    
    func loadMoreMessages(callback: (() -> Void)? = nil) {
        let paginationStep = 15
        let countRequestedMessages = paginationStep + self.messages.count
        loadMessages(countMessages: UInt(countRequestedMessages), callback: callback)
    }
    
    fileprivate func loadMessages(countMessages: UInt, callback: (() -> Void)? = nil) {
        let query = messagesReference.queryOrdered(byChild: "timestamp").queryLimited(toLast: countMessages)
        query.keepSynced(true)
        
        query.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            self?.getChatMessages(from: snapshot, callback: { messages in
                self?.messagesDictionary = messages
                callback?()
            })
        }) { (error) in
            callback?()
        }
    }
    
    private func getChatMessages(from snapshot: DataSnapshot, callback: @escaping (([String:JSQMessage]) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var messages: [String: JSQMessage] = [:]
            
            if  snapshot.exists(),
                let dictionary = snapshot.value as? [String: AnyObject] {
                for value in dictionary {
                    if let dict = value.value as? [String: AnyObject] ,let message = self?.getChatMessage(from: dict) {
                        messages[message.1] = message.0
                    }
                }
            }
            
            DispatchQueue.main.async {
                callback(messages)
            }
        }
    }
    
    private func getChatMessage(from value: [String: AnyObject]) -> (JSQMessage, String)? {

        let message = ChatMessage(dictionary: value)
        
        let messageId = message.messageId
        guard !messageId.isEmpty,
            let jsqMessage = message.jsqMessage else {
                return nil
        }
        
        return (jsqMessage, messageId)
    }
    
    func accept() {
        SVProgressHUD.show()
        accepted?.myAccept?.accept = .accepted
        Database.ChatAccept.change(status: .accepted, acceptID: accepted?.id ?? "")
        Database.ProfileBlock.unblock(profile: recever?.id ?? "", callback: { (finish) in
            SVProgressHUD.dismiss()
        })
        
    }
    
    func decline() {
        accepted?.myAccept?.accept = .reject
        Database.ChatAccept.change(status: .reject, acceptID: accepted?.id ?? "")
    }
    
}

//MARK: - App lifecycle
extension BaseChatViewModel {
    
    fileprivate func trackLifecycle() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.appBecameInactive(notification: )), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appBecameActive(notification: )), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func appBecameActive(notification: NSNotification) {
        self.fetchAllNewMessagesTimer?.invalidate()
        self.fetchAllNewMessagesTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { [weak self] _ in
            if let fetchAllNewMessagesFirebaseObserversId = self?.fetchAllNewMessagesFirebaseObserversId {
                self?.database.removeObserver(withHandle: fetchAllNewMessagesFirebaseObserversId)
            }
        })
        enableIncommingMessageSound()
    }
    
    @objc private func appBecameInactive(notification: NSNotification) {
        self.fetchAllNewMessagesTimer?.invalidate()
        if let fetchAllNewMessagesFirebaseObserversId = self.fetchAllNewMessagesFirebaseObserversId {
            self.database.removeObserver(withHandle: fetchAllNewMessagesFirebaseObserversId)
        }
        self.fetchAllNewMessagesFirebaseObserversId = subscribeForNewMessages(toLast: nil)
        self.canPlayIncommingMessageSound = false
    }
    
}

// listeners
extension BaseChatViewModel {
    fileprivate func subscribeMessageForChangesIfNeeded(key: String, message: JSQMessage) {
        guard (!message.isIncomming || message.type == .image),
            self.firebaseUpdateMessagesObserversIds[key] == nil else {
                return
        }
        
        let statusQuery = self.messagesReference.child(key)
        let childChangedStausId = statusQuery.observe(.childChanged, with: { [weak self] snapshot in
            guard snapshot.exists() else {
                return
            }
            
            if snapshot.key == "status",
                let statusString = snapshot.value as? String,
                let status = ChatMessageStatus(rawValue: statusString) {
                message.status = status
            }
            else if snapshot.key == "url",
                let url = snapshot.value as? String {
                message.attachmentURL = URL(string: url)
            } else {
                return
            }
            
            self?.messagesDictionary[key] = message
        })
        
        self.firebaseUpdateMessagesObserversIds[key] = childChangedStausId
    }
}

// MARK: - Firebase+UserTyping
extension BaseChatViewModel {
    
    fileprivate func subscribeForUserTypingStatus(in chat: ARChat) {
        let typingRef = database.child("user-typing").child(self.chat.id)
        
        //added
        let typindChildAddedId = typingRef.observe(.childAdded, with: { [weak self]
            (snapshot) in
            guard snapshot.exists(),
                let werakSelf = self,
                snapshot.key != ARUser.currentUser?.nickName ?? "" else {
                    return
            }
            
            werakSelf.typingTimer?.invalidate()
            werakSelf.typingTimer = nil
            werakSelf.typingTimer = Timer.scheduledTimer(timeInterval: 5, target: werakSelf, selector: #selector(werakSelf.stopTyping(timer:)), userInfo: ["parrentId": snapshot.key], repeats: false)
            self?.usersTyping.insert(snapshot.key)
        })
        
        //remove
        let typindChildRemovedId = typingRef.observe(.childRemoved, with: { [weak self]
            snapshot in
            guard snapshot.exists() else {
                return
            }
            self?.typingTimer?.invalidate()
            self?.typingTimer = nil
            
            self?.usersTyping.remove(snapshot.key)
        })
        
        self.firebaseObserversIds.append(typindChildAddedId)
        self.firebaseObserversIds.append(typindChildRemovedId)
    }
    
    @objc func stopTyping(timer: Timer) {
        if let dict = timer.userInfo as? [String: Any], let parrentID = dict["parrentId"] as? String {
            FirebaseMethods.sharedInstance.userIsTyping(chatRoom: chat.id, value: false, userName: parrentID)
            stopTyping()
        }
    }
}

// MARK: - Firebase+Messages
extension BaseChatViewModel {
    
    var messagesReference: DatabaseReference {
        return database.child("chat-rooms").child(self.chat.id).child("users").child(self.chat.me).child("chats")
    }
    
}


// MARK: - Send message
extension BaseChatViewModel {
    
    func startTyping() {
        sendMessage(text: ARUser.currentUser?.id ??  "", type: .typing, to: self.chat)
    }
    
    func stopTyping() {
        messagesDictionary.filter({$0.value.type == .typing && $0.value.senderId == ARUser.currentUser?.id ?? ""}).forEach({ (message) in
            chat.participans.forEach({ (participentID) in
                Database.Message.remove(message.key, participantID: participentID, chat: chat)
            })
        })
    }
    
    func sendMessage(with text: String) {
        chack { (send, errorMessage, type) in
            if send == true {
                self.sendMessage(text: text, type: .text, to: self.chat)
                ChatSoudEffectsPlayer.shared.play(effect: .sendMessage)
                
            } else {
                switch type {
                case 1:
                    showAlert(errorMessage)
                    break
                case 2:
                    let actionSheet = UIAlertController.init(title: errorMessage, message: nil, preferredStyle: .actionSheet)
                    
                    let unblockAction = UIAlertAction.init(title: "Разблокировать", style: .default, handler: { (action) in
                        self.accept()
                        self.sendMessage(text: text, type: .text, to: self.chat)
                        ChatSoudEffectsPlayer.shared.play(effect: .sendMessage)
                    })
                    
                    actionSheet.addAction(unblockAction)
                    actionSheet.addAction(UIAlertAction.init(title: "Отмена", style: .cancel, handler: nil))
                    actionSheet.show()
                    //                    if let tabbar = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                    //                        tabbar.selectedViewController?.present(actionSheet, animated: true, completion: nil)
                    //                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func sendMessage(text: String = "",
                             url: String = "",
                             type: ChatMessageType,
                             to chat: ARChat) {
        let messageId = Database.Message.createEmpty(for: chat.me, in: chat)
        
        for participant in chat.participans {
            if accepted?.reciverAccept?.userID == participant {
                if accepted?.reciverAccept?.accept != .reject {
                    sendMessage(messageId: messageId, text: text, url: url, type: type, participantID: participant, chat: chat)
                }
            } else {
                sendMessage(messageId: messageId, text: text, url: url, type: type, participantID: participant, chat: chat)
            }
        }
        
        if type != .typing {
            self.accept()
            PushNotification.sharedInstance.sendMessagePush(to: chat, reciverToken: recever?.DCS ?? "", body: "Новое сообщение от @\(me?.nickName ?? "")")
        }
    }
    
    func sendMessage(messageId: String,
                     text: String = "",
                     url: String = "",
                     type: ChatMessageType,
                     participantID: String,
                     chat: ARChat) {
        
        let message = ChatMessage.createMessage(id: messageId,
                                                text: text,
                                                url: url,
                                                type: type,
                                                for: chat)
        
        if participantID.isMe(),
            let jsqMessage = message.jsqMessage {
            self.messagesDictionary[messageId] = jsqMessage
            
            if accepted?.reciverAccept?.accept != .reject {
                Database.Inbox.update(chat: chat, sender: ARUser.currentUser!, reciver: recever!, message: jsqMessage)
            }
        }
        
        Database.Message.send(message, participantID: participantID, chat: chat)
        
    }
    
    func fetchAccept(completion handler:((ARChatAccept?)->Void)?) {
        Database.ChatAccept.accepted(by: chat.id) {[weak self] (accepted) in
            self?.accepted = accepted
            handler?(accepted)
        }
    }
    
    func sendMessage(with image: UIImage) {
        
        guard let resizedImage = image.resize(toWidth: 640),
            let data = UIImageJPEGRepresentation(resizedImage, 0.8) else {
                return
        }
        
        let temporaryUrl = "https://alien.com/\(Date().timeIntervalSince1970).jpg"
        ImageCache.default.store(resizedImage, forKey: temporaryUrl)
        sendMessage(with: data, text: "Image", temporaryUrl: temporaryUrl, type: .image) { url in
            if let url = url {
                ImageCache.default.removeImage(forKey: temporaryUrl)
                ImageCache.default.store(resizedImage, forKey: url, completionHandler: {
                    print("image uploaded")
                })
            }
        }
        
        ChatSoudEffectsPlayer.shared.play(effect: .sendMessage)
    }
    
    private func sendMessage(with data: Data, text: String, temporaryUrl: String? = nil, type: ChatMessageType, callBack: ((String?) -> Void)? = nil) {
        let messageId = Database.Message.createEmpty(for: chat.me, in: chat)
        
        for participant in self.chat.participans {
            if let temporaryUrl = temporaryUrl {
                self.sendImageMessage(messageId: messageId, text: text, url: temporaryUrl, type: type, participantID: participant, chat: chat)
            }
            
            Storage.putData(data) {[weak self] (url, errorMessage) in
                guard let wSelf = self else {return}
                if let url = url?.absoluteString {
                    if temporaryUrl != nil {
                        Database.Message.updateAttachmentUrl(messageId, participantID: participant, chat: wSelf.chat, url: url)
                    } else {
                        wSelf.sendImageMessage(messageId: messageId, text: text, url: url, type: type, participantID: participant, chat: wSelf.chat)
                    }
                }
                
                if participant.isMe() {
                    
                    Database.Inbox.update(chat: wSelf.chat, sender: ARUser.currentUser!, type: type, reciver: wSelf.recever!)
                    PushNotification.sharedInstance.sendMessagePush(to: wSelf.chat, reciverToken: wSelf.recever?.DCS ?? "", body: "Новое сообщение от @\(wSelf.me?.nickName ?? "")")

                    callBack?(url?.absoluteString)
                }
            }
        }
    }
    
    
    
    func sendImageMessage(messageId: String,
                          text: String = "",
                          url: String = "",
                          type: ChatMessageType,
                          participantID: String,
                          chat: ARChat) {
        
        let message = ChatMessage.createMessage(id: messageId,
                                                text: text,
                                                url: url,
                                                type: type,
                                                for: chat)
        
        if participantID.isMe(),
            let jsqMessage = message.jsqMessage {
            self.messagesDictionary[messageId] = jsqMessage
        }
        
        Database.Message.send(message, participantID: participantID, chat: chat)
        DispatchQueue.global(qos: .userInitiated).async {
            
            Database.Inbox.update(chat: chat, sender: ARUser.currentUser!, type: .image, reciver: self.recever!)
        }
    }
    
}






