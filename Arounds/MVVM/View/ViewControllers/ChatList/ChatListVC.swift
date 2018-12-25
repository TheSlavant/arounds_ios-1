//
//  ChatListVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/4/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SVProgressHUD
import Firebase
import UIKit
import FirebaseUtils

class ChatListVC: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: ARSearch!
    @IBOutlet weak var lastMsgLabel: UILabel!
    var handle: DatabaseHandle?

    var openRadarChat: Bool = false {
        didSet {
            //            if openRadarChat == true {
            //                openRadarChat = false
            //                performSegue(withIdentifier: "radarListSegue", sender: self)
            //            }
        }
    }
    var isPresentedcChatVC: Bool = false
    var fromNotificationChatID: String? {
        didSet {
            if let chatRoomID = fromNotificationChatID, let inbox = inboxes.filter({$0.chatID == chatRoomID}).first {
                if isPresentedcChatVC == false {
                    openChatByID(inbox: inbox)
                }
            }
        }
    }
    
    let ref = Database.database().reference().child("allMSG")
    
    var lastMsg:RadarMessage? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.lastMsgLabel.text = self?.lastMsg?.text
            }
        }
        
    }
    
    var filteredInboxes = [ARInbox]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var inboxes = [ARInbox]() {
        didSet {
            filteredInboxes = inboxes
            if let chatRoomID = fromNotificationChatID, let inbox = inboxes.filter({$0.chatID == chatRoomID}).first {
                if isPresentedcChatVC == false {
                    openChatByID(inbox: inbox)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        lastMsgLabel.text = "Сообщений пока нет😭"
        
        
        Database.database().reference()
            .child(kRadar_inbox)
            .child(ARUser.currentUser?.id ?? "")
            .child("radarMessages")
            .observe(.value) {[weak self] (snapshot) in
                if snapshot.exists(), let messages = snapshot.value as? [String] {
                    
                    Database.database().reference()
                        .child(kRadar_messages)
                        .observe(.value, with: { (snapshot) in
                            if snapshot.exists(), let dict = snapshot.value as? [String : Any] {
                                let filtered = dict.filter({messages.contains($0.key)})
                                let maped = filtered.map({ (obj) -> RadarMessage in
                                    return RadarMessage.init(with: obj.value as! [String: Any], messageID: obj.key)
                                })
                                self?.lastMsg = maped.sorted(by: { (obj1, obj2) -> Bool in
                                    return obj1.date > obj2.date
                                }).first
                                
                            }
                        })
                }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.textField.placeholder = "Поиск по сообщениям"
        searchBar.textField.delegate = self
        isPresentedcChatVC = false
        
        let imageView = UIImageView(image: backgroundView.toImage())
        self.tableView.backgroundView = imageView
        if openRadarChat == true {
            openRadarChat = false
            performSegue(withIdentifier: "radarListSegue", sender: self)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Database.Inbox.inboxes { [weak self] (newInboxes) in
            //            SVProgressHUD.dismiss(completion: {
            self?.inboxes = newInboxes.sorted(by: { (obj1, obj2) -> Bool in
                return (obj1.date > obj2.date)
                //                })
            })
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension ChatListVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        ref.removeAllObservers()
        if textField.text?.count == 1 && (string == "" || string == " ") {
            filteredInboxes = inboxes
            tableView.reloadData()
            return true
        }
        
        self.filteredInboxes = [ARInbox]()
        self.tableView.reloadData()

        let fullText = (textField.text ?? "").appending(string).lowercased()
        handle = ref.observe(.value) { [weak self] (snapshot) in
            self?.ref.removeObserver(withHandle: self?.handle ?? 0)
            
            if let dict = snapshot.value as? [String: [String: Any]]
            {
                let myMSG = dict.filter({(($0.value["participans"] as? [String])?.contains(ARUser.currentUser?.id ?? "")) ?? false})
                self?.filteredInboxes = [ARInbox]()
                self?.filteredInboxes += myMSG.filter({ (obj) -> Bool in
                    let text = obj.value["text"] as? String ?? ""
                    return text.lowercased().contains(fullText)
                }).map({ARInbox.init(with: $0.value, inboxId: $0.key)})
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    
                }
            }

        }
        
        
        filteredInboxes += inboxes.filter({ (inbox) -> Bool in
            return (inbox.text ?? "").lowercased().contains(fullText) || (inbox.displayName ?? "").lowercased().contains(fullText)
        })
        //
        //        tableView.reloadData()
        //
        
        return true
    }
    
}


extension ChatListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredInboxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath) as! MessageListCell
        cell.inbox = filteredInboxes[indexPath.row]
        if searchBar.textField.text?.isEmpty != true {
            cell.seenView.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inbox = filteredInboxes[indexPath.row]
        openChatByID(inbox: inbox)
    }
    
    func  openChatByID(inbox: ARInbox) {
        SVProgressHUD.show()
        isPresentedcChatVC = true
        fromNotificationChatID = nil
        
        Database.Chat.getChat(chatID: inbox.chatID) { (chat) in
            SVProgressHUD.dismiss(completion: {
                if let chat = chat {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        let vc = OneToOneVC.create(with: chat)
                        self.present(vc, animated: true, completion: nil)
                        if (inbox.senderID != ARUser.currentUser?.id ?? "") && inbox.seen == false {
                            Database.database().reference().child(kUser_inbox).child(inbox.id).child("seen").setValue(true)
                        }
                    })
                }
            })
        }
        
    }
}



