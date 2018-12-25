//
//  AlienMessagesBubbleImage.swift
//  Alien Chat
//
//  Created by Yaroslav Voloshyn on 13/12/2017.
//  Copyright © 2017 Yaroslav Voloshyn. All rights reserved.
//

import UIKit

import JSQMessagesViewController.JSQMessagesBubbleImage

final class MessagesBubbleImage {

    static let outgoingBubbleImageView: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(),
                                             capInsets: .zero).outgoingMessagesBubbleImage(with: .clear)
    }()

    static let incomingBubbleImageView: JSQMessagesBubbleImage  = {
        return JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(),
                                             capInsets: .zero).incomingMessagesBubbleImage(with: .clear)
    }()

}
