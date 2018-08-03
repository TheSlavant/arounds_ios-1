//
//  ARProfileBlock.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/19/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import Foundation

fileprivate let kMyBlock = "myBlock"

enum BlockLavel: Int {
    case first = 3
    case secound = 14
    case forever = 24
}

class ARProfileBlock {
    var id: String!
    var profileID: String!
    var blockCount: Int = 0
    var blockList: [String] = [String]()
    var blockListByMe: [String] = [String]() // list of blocked users by me (nranq um es em block arel)
    
    var blockLavel: Int = 0
    var blockStart: Date?
    var blockFinish: Date?
    
    private var blockedView = ARBlockedView.shared
    
    static func newBlockModel() -> [String: Any] {
        return ["blockCount" : 0, "profileID" : (ARUser.currentUser?.id ?? ""), "blockLavel" : 0]
    }
    
    func save() {
        var dict:[String: Any] = ["blockCount" : blockCount,
                                  "blockList" : blockList,
                                  "id" : id,
                                  "profileID" : profileID,
                                  "blockListByMe" : blockListByMe,
                                  "blockLavel" : blockLavel]
        
        if let blockStart = blockStart {
            dict["blockStart"] = blockStart.timeIntervalSince1970
        }
        
        if let blockFinish = blockFinish {
            dict["blockFinish"] = blockFinish.timeIntervalSince1970
        }
        
        UserDefaults.standard.set(dict, forKey: kMyBlock)
        UserDefaults.standard.synchronize()
    }
    
    static func rebase() -> ARProfileBlock {
        let block = ARProfileBlock()
        
        if let dict = UserDefaults.standard.value(forKey: kMyBlock) as? [String:Any] {
            
            block.blockListByMe = dict["blockListByMe"] as? [String] ?? [String]()
            block.blockList = dict["blockList"] as? [String] ?? [String]()
            block.blockCount = dict["blockCount"] as? Int ?? 0
            block.profileID = dict["profileID"] as? String
            block.id = dict["id"] as? String ?? ""
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
    
    func prefil(dict: (key: String, value: [String: Any] )) {
        id = dict.key
        blockCount = dict.value["blockCount"] as? Int ?? 0
        profileID = dict.value["profileID"] as? String
        blockListByMe = (dict.value["blockListByMe"] as? [String]) ?? [String]()
        blockList = (dict.value["blockList"] as? [String]) ?? [String]()
        
        blockLavel = dict.value["blockLavel"] as? Int ?? 0
        if let startDict = dict.value["blockStart"] {
            blockStart = Date(timeIntervalSince1970: startDict as? Double ?? 0)
        }
        if let finishDict = dict.value["blockFinish"] {
            blockFinish = Date(timeIntervalSince1970: finishDict as? Double ?? 0)
        }
    }
    
    init(with dict: (key: String, value: [String: Any] ) ) {
        prefil(dict: dict)
    }
    
    var isInProcess = false
    
    func chackLavel() {
        if isInProcess == true {return}
        if blockCount < BlockLavel.first.rawValue && (blockStart != nil || blockFinish != nil) {
            stopBlocking(lavel: 0)
            return
        }
        
        if blockCount == BlockLavel.first.rawValue && blockLavel == 0 && blockFinish == nil {
            if blockedView.isPresented == false {
                let date =  Calendar.current.date(byAdding: Calendar.Component.day, value: 3, to: Date())
                Database.ProfileBlock.startBlocking(blockID: ARProfileBlock.rebase().id, lavel: 1, finish: date ?? Date())
                blockStart = Date()
                blockFinish = date
                save()
                isInProcess = false
            }
        } else if blockCount == BlockLavel.secound.rawValue && blockLavel == 1 {
            if blockedView.isPresented == false {
                let date =  Calendar.current.date(byAdding: Calendar.Component.day, value: 14, to: Date())
                Database.ProfileBlock.startBlocking(blockID: ARProfileBlock.rebase().id, lavel: 2, finish: date ?? Date())
                blockStart = Date()
                blockFinish = date
                save()
                isInProcess = false
            }
        } else if blockCount == BlockLavel.forever.rawValue && blockLavel == 2 {
            if blockedView.isPresented == false {
                Database.ProfileBlock.startBlocking(blockID: ARProfileBlock.rebase().id, lavel: 3, finish: nil)
                blockStart = Date()
                blockFinish = nil
                save()
                isInProcess = false
            }
        }
        
        
        if let finish = blockFinish, finish < Date()/* if block finished */ {
            
            stopBlocking(lavel: blockLavel + 1)
        } else if let _ = blockStart {
            blockedView.endDate = blockFinish
            blockedView.show()
            isInProcess = false
        }
        save()
        isInProcess = false
    }
    
    func stopBlocking(lavel: Int) {
        isInProcess = true
        blockStart = nil
        blockFinish = nil
        save()
        blockedView.hide()
        Database.ProfileBlock.stopBlocking(blockID: ARProfileBlock.rebase().id, blockLavel: lavel) { (finish) in
            self.isInProcess = false
        }
        
    }
    
    
}
