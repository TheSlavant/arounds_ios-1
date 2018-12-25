//
//  MessageCell.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/6/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import JSQMessagesViewController.JSQMessage

protocol MessageCell {
    
    func updateView(with message: JSQMessage)
    
}

extension MessageCell {
    
    func getStatusColor(for message: JSQMessage) -> UIColor {
        switch message.status {
        case .sent:
            return UIColor.orange
        case .delivered:
            return UIColor.blue
        case .seen:
            return UIColor.withHex("#27AE60")
        case .failed:
            return UIColor.white
        }
        
    }
    
    func getBubble(for message: JSQMessage) -> UIImage {
        if message.isIncomming {
            return MessagesBubbleImage.incomingBubbleImageView.messageBubbleImage
        }
        return MessagesBubbleImage.outgoingBubbleImageView.messageBubbleImage
    }
    
    func getFormattedDate(for message: JSQMessage) -> String? {
        let formatter = DateFormatter()
        if let date = message.date {
            if NSCalendar.current.isDateInToday(date) {
                formatter.dateFormat = "HH:mm"
                return "Сегодня, \(formatter.string(from: date))"
            } else if NSCalendar.current.isDateInYesterday(date) {
                formatter.dateFormat = "HH:mm"
                return "Вчера, \(formatter.string(from: date))"
            }
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.string(from: date)
        }
        
        return nil
    }
}
