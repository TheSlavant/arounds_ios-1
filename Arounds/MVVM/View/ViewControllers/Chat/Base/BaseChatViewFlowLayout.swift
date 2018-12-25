//
//  BaseChatViewFlowLayout.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/8/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import JSQMessagesViewController

final class BaseChatViewFlowLayout: JSQMessagesCollectionViewFlowLayout {
    
    override func messageBubbleSizeForItem(at indexPath: IndexPath!) -> CGSize {
        let size = super.messageBubbleSizeForItem(at: indexPath)
        
        if size.width < 62 {
            return CGSize(width: 62, height: size.height)
        }
        
        return size
    }
    
    
    
}
