//
//  ARMessageBlock.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/21/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase
import Foundation

fileprivate let kMessageBlock = "messageBlock"

enum MessageBlockLavel: Int {
    case first = 1
    case secound = 2
    case forever = 3
}

class ARMessageBlock {
    var blockLavel: Int = 0
    var blockStart: Date?
    var blockFinish: Date?
    
    private var blockedView = ARBlockedView.shared

    func save() {
        var dict:[String: Any] = ["blockLavel" : blockLavel]
        
        if let blockStart = blockStart {
            dict["blockStart"] = blockStart.timeIntervalSince1970
        }
        
        if let blockFinish = blockFinish {
            dict["blockFinish"] = blockFinish.timeIntervalSince1970
        }
        
        UserDefaults.standard.set(dict, forKey: kMessageBlock)
        UserDefaults.standard.synchronize()
    }
    
    static func rebase() -> ARMessageBlock {
        let block = ARMessageBlock()
        
        if let dict = UserDefaults.standard.value(forKey: kMessageBlock) as? [String:Any] {
            
            block.blockLavel = dict["blockLavel"] as? Int ?? 0
            if let blockStartInterval = dict["blockStart"] as? Double {
                block.blockStart = Date(timeIntervalSince1970: blockStartInterval)
            }
            
            if let blockFinishInterval = dict["blockFinish"] as? Double {
                block.blockFinish = Date(timeIntervalSince1970: blockFinishInterval)
            }
            
        }
        return block
    }

    private init() {}
    
    func prefil(dict: [String: Any]) {
        
        blockLavel = dict["blockLavel"] as? Int ?? 0
        if let startDict = dict["blockStart"] as? Double {
            blockStart = Date(timeIntervalSince1970: startDict)
        }
        if let finishDict = dict["blockFinish"] as? Double, finishDict != 0 {
            blockFinish = Date(timeIntervalSince1970: finishDict)
        }
    }
    
    init(with dict: [String: Any]) {
        prefil(dict: dict)
    }

    func chackLavel() {
        
        if blockLavel == 0 && (blockStart != nil || blockFinish != nil) {
            stopBlocking(lavel: 0)
            return
        }
        
        if let finish = blockFinish, finish < Date()/* if block finished */ {
            
            stopBlocking(lavel: blockLavel + 1)
        } else if let _ = blockStart {
            blockedView.endDate = blockFinish
            blockedView.show()
        }
        save()
    }
    
    func stopBlocking(lavel: Int) {
        blockStart = nil
        blockFinish = nil
        save()
        blockedView.hide()
        Database.MessageBlock.stopBlocking(blockerID: ARUser.currentUser?.id ?? "", blockLavel: lavel) { (finish) in
        }
        
    }


}
