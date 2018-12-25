//
//  RadarListVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SVProgressHUD
import Firebase
import UIKit

class RadarListVC: UIViewController {
    
    @IBOutlet weak var messageCounts: UILabel!
    @IBOutlet weak var tableView: UITableView!
    lazy var user: ARUser? = ARUser.currentUser
    var messages = [RadarMessage]()
    var unreadInboxCount: Int = 0 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        Database.database().reference()
            .child(kRadar_inbox)
            .child(user?.id ?? "")
            .child("radarMessages")
            .observe(.value) {[weak self] (snapshot) in
                if snapshot.exists(), let messages = snapshot.value as? [String] {
                    
                    Database.database().reference()
                        .child(kRadar_messages)
                        .observe(.value, with: { (snapshot) in
                            guard let weakSelf = self else {return}
                            if snapshot.exists(), let dict = snapshot.value as? [String : Any] {
                                let filtered = dict.filter({messages.contains($0.key)})
                                let maped = filtered.map({ (obj) -> RadarMessage in
                                    return RadarMessage.init(with: obj.value as! [String: Any], messageID: obj.key)
                                })
                                weakSelf.messages = maped.sorted(by: { (obj1, obj2) -> Bool in
                                    return obj1.date > obj2.date
                                })
                                let set:Set = Set(weakSelf.messages.map({$0.senderID}))
                                weakSelf.messageCounts.text = "\(set.count)"
                                weakSelf.tableView.reloadData()
                            }
                        })
                }
        }
        
        // Do any additional setup after loading the view.
    }
    
        override var prefersStatusBarHidden: Bool {
        return false
    }

    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension RadarListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "radarMessage", for: indexPath) as! RadarMessageCell
        cell.message = messages[indexPath.row]
       
//        cell.didBlockMessage = { messageID, senderID, blockers in
//            let message = self.messages.filter({$0.id == messageID}).first
//            Database.RadarMessage.block(messageID: messageID, senderID: senderID, blockers: message?.blockers ?? [String]())
//        }
        
        
        return cell
    }
}







