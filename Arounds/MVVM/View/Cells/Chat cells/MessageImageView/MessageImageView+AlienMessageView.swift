//
//  MessageImageView+MessageView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import JSQMessagesViewController.JSQMessage
import Kingfisher

extension MessageImageView: MessageCell {
    
    func updateView(with message: JSQMessage) {
//        self.backgroundImageView.image = getBubble(for: message)
//
//        self.outgoingMessageTimeLabel.text = nil
//        self.incommingMessageTimeLabel.text = nil
//        let timeLabel = message.isIncomming ? self.incommingMessageTimeLabel : self.outgoingMessageTimeLabel
//        timeLabel?.text = getFormattedDate(for: message)
//
//        if message.isIncomming == false {
//            if message.type == .image {
//                if message.status == .failed {
//                    self.activityIndicatorView.isHidden = false
//                    self.activityIndicatorView.startAnimating()
//                }else {
//                    self.activityIndicatorView.stopAnimating()
//                    self.activityIndicatorView.isHidden = true
//                }
//            }
//        }
        
//        self.iconImageView.layer.cornerRadius = 15
//        self.iconImageView.clipsToBounds = true
        //        self.activityIndicatorView.isHidden = false
//            if self.iconImageView.image == nil {
//
//                self.iconImageView.kf.setImage(with: message.attachmentURL, options: [.fromMemoryCacheOrRefresh, .keepCurrentImageWhileLoading, .downloadPriority(1)]) { [weak self] (image, error, _, _) in
//                    self?.activityIndicatorView.isHidden = image != nil
//                }
//            }

//        self.outgoingMessageStatusImageView.isHidden = message.isIncomming
//        self.outgoingMessageStatusImageView.tintColor = getStatusColor(for: message)
    }
    
}
