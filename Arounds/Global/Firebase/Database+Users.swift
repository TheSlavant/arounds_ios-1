//
//  Database+Users.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import CoreLocation
import Firebase

fileprivate let users = "users"

extension Database {
    
    enum Users: DatabaseAccess {
        
        static func users(by arrayUser:[(String, CLLocation)], completion handler:(([ARUser])->Void)?) {
            
            let userID = arrayUser.map({$0.0})
            let contactRef = database.child("users")
            _ = contactRef.observe(DataEventType.value, with: { (snapshot) in
                
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                // filtering users, mapint dict to ARUser object
                let filtered = postDict.filter({ (arg) -> Bool in
                    return userID.contains(arg.key)
                })
                
                let maped = filtered.map({ (arg) -> ARUser in
                    //
                    var user = ARUser()
                    if let userDict = arg.value as? [String: Any], let location = arrayUser.filter({$0.0 == arg.key}).first?.1 {
                        user = ARUser.init(with: userDict)
                        user.id = arg.key
                        user.coordinate = ARCoordinate(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                        return user
                    }
                    //
                    return user
                })
                
                print(maped)
                handler?(maped)
            })
        }
        
        static func setSocial(social: ARSocial, userID: String) {
            database.child("social").child(userID).setValue(social.toDict())
        }
        
        static func social(userID: String, completion handler:((ARSocial?)->Void)?){
            
          let ref = database.child("social").child(userID)
            ref.observe(.value) { (snapshot) in
                if let dict = snapshot.value as? [String : String] {
                    handler?(ARSocial.init(dict: dict))
                    return
                }
                handler?(nil)
            }
            
        }
    }
    
}
