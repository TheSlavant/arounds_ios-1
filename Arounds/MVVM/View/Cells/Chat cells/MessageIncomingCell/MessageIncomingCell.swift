//
//  messageViewIncoming.swift
//  PGP Chat
//
//  Created by Muhammad Shabbir on 8/18/17.
//  Copyright © 2017 Muhammad Shabbir. All rights reserved.
//

import UIKit
import JSQMessagesViewController

final class MessageIncomingCell: JSQMessagesCollectionViewCellIncoming {

    @IBOutlet weak var bubleImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    var type: ChatMessageType!
    var reciver: ARUser?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override class func nib() -> UINib {
        return UINib(nibName: MessageIncomingCell.nameOfClass, bundle: nil)
    }

    override class func cellReuseIdentifier() -> String {
        return MessageIncomingCell.nameOfClass
    }
    
}
