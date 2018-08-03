//
//  AttachmentMessageMediaData.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/6/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import JSQMessagesViewController.JSQMessageMediaData

final class AttachmentMessageMediaData: NSObject, JSQMessageMediaData {
    
    weak var message: JSQMessage!
    
    func mediaView() -> UIView! {
        let mediaView = self.message.type.mediaView
        
        if let messageView = mediaView as? MessageCell {
            messageView.updateView(with: self.message)
        }
        
        return mediaView
    }
    
    func mediaViewDisplaySize() -> CGSize {
        switch self.message.type {
        case .image:
            return CGSize(width: 150, height: 100)
        case .voice:
            return CGSize(width: 200, height: 50)
        default:
            return .zero
        }
    }
    
    func mediaPlaceholderView() -> UIView! {
        return nil
    }
    
    func mediaHash() -> UInt {
        return 0
    }
}

private extension ChatMessageType {
    
    var mediaView: UIView! {
        let viewName: String!
        
        switch self {
        case .image:
            viewName = "MessageImageView"
        case .voice:
            viewName = "MessageVoiceView"
        default:
            return nil
        }
        
        return Bundle.main.loadNibNamed(viewName, owner: nil, options: nil)!.first as? UIView
    }
}
