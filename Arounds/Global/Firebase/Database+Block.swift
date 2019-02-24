//
//  Database+Block.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/18/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

import Firebase

let kProfile_block = "profile-block"
let kMessage_block = "message_block"

extension Database {

    enum ProfileBlock: DatabaseAccess {
        
        static func block(profile userID: String, callback: @escaping ((Bool) -> Void)) {
            
            database.child(kProfile_block).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(),
                    let dict = snapshot.value as? [String: [String: Any]],
                    let userDict = dict.filter({ ($0.value["profileID"] as? String ?? "") == userID }).first
                {
                    
                    let blockList = userDict.value["blockList"] as? [String] ?? [String]()
                    let blockCount = userDict.value["blockCount"] as? Int ?? 0
                    
                    // list of blocked users by me (nranq um es em block arel)
                    var blockListByMe = ARProfileBlock.rebase().blockListByMe
                    blockListByMe.append(userID)

                    var set = Set.init(blockList)
                    set.insert(ARUser.currentUser?.id ?? "")
                    database.child(kProfile_block).child(userDict.key).updateChildValues(["blockCount" : blockCount + 1])
                    database.child(kProfile_block).child(userDict.key).updateChildValues(["blockList" : Array.init(set)])
                    
                    database.child(kProfile_block).child(ARProfileBlock.rebase().id).updateChildValues(["blockListByMe":blockListByMe])

                    callback(true)
                } else {
                    _ = ProfileBlock.createEmpty(with: userID)
                    ProfileBlock.block(profile: userID, callback: { (finish) in
                        callback(finish)
                    })
                }
            }
        }
        
        static func unblock(profile userID: String, callback: @escaping ((Bool) -> Void)) {
            
            database.child(kProfile_block).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(),
                    let dict = snapshot.value as? [String: [String: Any]],
                    let userDict = dict.filter({ ($0.value["profileID"] as? String ?? "") == userID }).first
                {
                    let blockList = userDict.value["blockList"] as? [String] ?? [String]()
                    
                    // list of blocked users by me (nranq um es em block arel)
                    var blockListByMe = ARProfileBlock.rebase().blockListByMe
                    if blockListByMe.count > 0 {
                        blockListByMe.remove(at: blockListByMe.index(of: userID) ?? 0)
                    }
                    
                    var set = Set.init(blockList)
                    set.remove(ARUser.currentUser?.id ?? "")
                    
                    database.child(kProfile_block).child(userDict.key).updateChildValues(["blockList" : Array.init(set)])
                    database.child(kProfile_block).child(ARProfileBlock.rebase().id).updateChildValues(["blockListByMe":blockListByMe])
                    
                    callback(true)
                    return
                }
                callback(true)
            }
        }
        
        static func createEmpty(with userID: String) {
            let newBlockID = database.child(kProfile_block).childByAutoId()
            newBlockID.setValue(["profileID" : userID])
        }
        
        static func myBlockID(callback: @escaping ((String?) -> Void)) {
            database.child(kProfile_block).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(),
                    let dict = snapshot.value as? [String: [String: Any]],
                    let myBlockId = dict.filter({ ($0.value["profileID"] as? String ?? "") == ARUser.currentUser?.id ?? ""}).first?.key
                {
                    callback(myBlockId)
                    return
                }
                callback(nil)
            }
            
        }
        
        static func userBlock(by userID: String, callback: @escaping ((ARProfileBlock?) -> Void)) {
            
            database.child(kProfile_block).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(),
                    let dict = snapshot.value as? [String: [String: Any]],
                    let myBlockId = dict.filter({ ($0.value["profileID"] as? String ?? "") == userID}).first
                {
                    callback(ARProfileBlock(with: myBlockId))
                    return
                }
                callback(nil)
            }
            
        }
        
        static func stopBlocking(blockID: String, blockLavel: Int, callback: @escaping ((Bool?) -> Void)) {
            
            database.child(kProfile_block).child(blockID).updateChildValues(["blockLavel" : blockLavel,
                                                                             "blockFinish": nil,
                                                                             "blockStart": nil])

            callback(true)
        }
        
        static func startBlocking(blockID: String, lavel: Int, finish: Date?) {
            
            
            database.child(kProfile_block).child(blockID).updateChildValues(["blockStart" : [".sv":"timestamp"],
                                                                             "blockFinish": lavel == 3 ? nil : finish!.timeIntervalSince1970])

        }

    }

}


extension Database {
    
    enum MessageBlock: DatabaseAccess {
        static func stopBlocking(blockerID: String, blockLavel: Int, callback: @escaping ((Bool?) -> Void)) {
            
            database.child(kProfile_block).child(blockerID).updateChildValues(["blockLavel" : blockLavel,
                                                                               "blockFinish": nil,
                                                                               "blockStart": nil])
            
            callback(true)
        }

    }
    
}
