//
//  Database+SearchUsers.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase

fileprivate let users = "users"

extension Database {
    
    enum Search: DatabaseAccess {
        
        static func find(by firstName: String, lastName: String? = nil, completion handler:(([ARUser])->Void)?) {
            let block = ARProfileBlock.rebase()
            
            if firstName == "" {
                handler?([ARUser]())
                return
            }
            database.child(users).removeAllObservers()
            database.child(users).observeSingleEvent(of: .value) { (snapshot) in
                var postDict = snapshot.value as? [String : [String: Any]] ?? [:]
                
                postDict = postDict.filter({ (obj) -> Bool in
                    return  ((obj.value["firstName"] as? String ?? "").lowercased().hasPrefix(firstName.lowercased()) || (obj.value["lastName"] as? String ?? "").lowercased().hasPrefix(firstName.lowercased()) ||
                    (obj.value["nickname"] as? String ?? "").lowercased().hasPrefix(firstName.lowercased()))
                })
                
                if let lastName = lastName {
                    postDict = postDict.filter({ (obj) -> Bool in
                        return  (obj.value["lastName"] as? String ?? "").lowercased().hasPrefix(lastName.lowercased())
                    })
                }
                
                // filtering users, who block me
                let withouthBlockers = postDict.filter({block.blockList.contains($0.key) != true})
                
                let maped = withouthBlockers.map({ (arg) -> ARUser in
                    let user = ARUser(with: arg.value)
                    user.id = arg.key
                    return user
                }).filter({$0.isBlocked == false})
                
                handler?(maped.filter({$0.id ?? "" != ARUser.currentUser?.id ?? "" && $0.isUpdated == true && $0.phone != "0000000000104"}))

            }
        }
    }
}
