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
        
        static func users(by phone:String, completion handler:((ARUser?)->Void)?) {
            
            let contactRef = database.child("users")
            
            contactRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(), let postDict = snapshot.value as? [String : AnyObject] {
                    if let user = postDict.filter({($0.value["phone"] as? String) == phone}).map({ (obj) -> ARUser in
                        let user = ARUser.init(with: obj.value as! [String : Any])
                        user.id = obj.key
                        return user
                    }).first {
                        handler?(user)
                        
                    } else  {
                        users(create: phone, completion: { (user) in
                            handler?(user)
                        })
                    }
                }else {
                    users(create: phone, completion: { (user) in
                        handler?(user)
                    })
                }
            }
        }
        
        
        static func users(create phone:String, completion handler:((ARUser)->Void)?) {
            let userRef = database.child("users").childByAutoId()
            let likesRef = database.child("likes")
            let socialRef = database.child("social")
            
            let newUser = ARUser()
            newUser.phone = phone
            newUser.id = userRef.key
            
            userRef.updateChildValues(newUser.empty())
            likesRef.updateChildValues([userRef.key: ""])
            socialRef.updateChildValues([userRef.key: [ "vk" : "",
                                                        "fb" : "",
                                                        "insta" : "",
                                                        "twiter" : ""]])
            
            
            handler?(newUser)
        }
        
        
        
        static func users(by arrayUser:[(String, CLLocation)], completion handler:(([ARUser])->Void)?) {
            let block = ARProfileBlock.rebase()
            let userID = arrayUser.map({$0.0})
            let contactRef = database.child("users")
            
            contactRef.observeSingleEvent(of: .value) { (snapshot) in
                
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                // filtering users, mapint dict to ARUser object
                let filtered = postDict.filter({ (arg) -> Bool in
                    return userID.contains(arg.key)
                })
                // filtering users, who block me
                let withouthBlockers = filtered.filter({block.blockList.contains($0.key) != true})
                
                let maped = withouthBlockers.map({ (arg) -> ARUser in
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
            }
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
        
        static func user(userID: String, completion handler:((ARUser?)->Void)?) {
            
            let ref = database.child("users").child(userID)
            ref.keepSynced(true)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                database.removeAllObservers()
                if let dict = snapshot.value as? [String: Any] {
                    let user = ARUser.init(with: dict)
                    user.id = userID
                    handler?(user)
                    return
                }
                handler?(nil)
                
            }
        }
        
        static func users(by limit: UInt, complition handler:(([ARUser])->Void)?) {
            let ref = database.child("users").queryLimited(toLast: limit + 1)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                let postDict = snapshot.value as? [String : [String: Any]] ?? [:]
                
                let maped = postDict.map({ (arg) -> ARUser in
                    let user = ARUser.init(with: arg.value)
                    user.id = arg.key
                    return user
                })
                
                let filtered = maped.filter({$0.id != ARUser.currentUser?.id ?? ""})
                
                if filtered.count > limit {
                    handler?(Array(filtered[0..<10]))
                    return
                }
                handler?(filtered)
            }
            
        }
        
        
        static func setOnline() {
            database.child("users").child(ARUser.currentUser?.id ?? "").updateChildValues(["lastOnlone" :[".sv":"timestamp"]])
        }
        
    }
    
}
