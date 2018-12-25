//
//  MessageVoiceView+MessageView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import JSQMessagesViewController.JSQMessage

extension MessageVoiceView: MessageCell {

    func updateView(with message: JSQMessage) {
        self.backgroundImageView.image = getBubble(for: message)
        self.url = message.attachmentURL
        self.outgoingMessageTimeLabel.text = nil
        self.incommingMessageTimeLabel.text = nil
        let timeLabel = message.isIncomming ? self.incommingMessageTimeLabel : self.outgoingMessageTimeLabel
        timeLabel?.text = getFormattedDate(for: message)

        self.playPauseImage.tintColor = message.isIncomming ? .black : .white
        self.outgoingMessageStatusImageView.isHidden = message.isIncomming
        self.outgoingMessageStatusImageView.tintColor = getStatusColor(for: message)
        
        playPauseImageLeftConstraint.constant = message.isIncomming ? 12 : 5
        progressViewTrailingConstraint.constant = message.isIncomming ? 15 : 23
    }

}
