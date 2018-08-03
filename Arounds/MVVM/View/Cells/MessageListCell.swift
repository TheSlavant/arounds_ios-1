//
//  MessageListCell.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/14/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import UIKit

class MessageListCell: UITableViewCell {
    
    @IBOutlet weak var seenView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var avatarIcon: ARRoundedImageView!
    var didFetchedUser: ((ARUser?) -> Void)?

    var sender: ARUser? {
        didSet {
            nickNameLabel.text = "@" + (sender?.nickName ?? "")
        }
    }
    
    var inbox: ARInbox? {
        didSet {
            guard let inbox = inbox, let userID = inbox.participans.filter({$0 != ARUser.currentUser?.id ?? ""}).first else {return}
            Database.Users.user(userID: userID) { [weak self] (user) in
                self?.sender = user
                self?.didFetchedUser?(user)
            }
            
            seenView.isHidden = !(!inbox.seen && inbox.senderID != ARUser.currentUser?.id ?? "")
            seenView.backgroundColor = UIColor.withHex("F94865")

            if inbox.senderID == ARUser.currentUser?.id ?? "" {
                avatarIcon.image = inbox.reciverImage()
                nickNameLabel.text = "@" + inbox.reciverName

            } else {
                avatarIcon.image = inbox.getImage()
                nickNameLabel.text = "@" + inbox.displayName
            }
            
            if inbox.type == .text {
                messageLabel.text = inbox.text
            } else if inbox.type == .image {
                messageLabel.text = "Фотография"
            } else if inbox.type == .voice {
                messageLabel.text = "Аудио"
            } else {
                messageLabel.text = "Фотография"
            }
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
