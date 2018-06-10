//
//  Database+Likes.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/25/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import CoreLocation
import Firebase

fileprivate let users = "users"

extension Database {
    
    enum Likes: DatabaseAccess {
        
        static func likes(userID: String, completion handler:(([String : AnyObject])->Void)?) {
            
            let contactRef = database.child("likes").child(userID)
            _ = contactRef.observe(DataEventType.value, with: { (snapshot) in
                handler?(snapshot.value as? [String : AnyObject] ?? [:])
            })
            
        }
        
        static func like(fromID: String, toID: String) {
            database.child("likes").child(toID).updateChildValues([fromID : true])
        }
        
        static func dislike(fromID: String, toID: String) {
            database.child("likes").child(toID).child(fromID).removeValue()
        }

    }
}

