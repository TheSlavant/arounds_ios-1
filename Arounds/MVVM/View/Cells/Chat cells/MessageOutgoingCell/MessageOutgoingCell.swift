//
//  MessageViewOutgoing.swift
//  PGP Chat
//
//  Created by Muhammad Shabbir on 8/18/17.
//  Copyright © 2017 Muhammad Shabbir. All rights reserved.
//

import UIKit
import JSQMessagesViewController

final class MessageOutgoingCell: JSQMessagesCollectionViewCellOutgoing {
    
    @IBOutlet weak var dateRightPading: NSLayoutConstraint!
    @IBOutlet weak var statusIconWidth: NSLayoutConstraint!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var bubleImageView: UIImageView!
    @IBOutlet weak var readView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusFontelloLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.backgroundColor = .red
    }
    
    override class func nib() -> UINib {
        return UINib(nibName: MessageOutgoingCell.nameOfClass, bundle: nil)
    }
    
    override class func cellReuseIdentifier() -> String {
        return MessageOutgoingCell.nameOfClass
    }
}
