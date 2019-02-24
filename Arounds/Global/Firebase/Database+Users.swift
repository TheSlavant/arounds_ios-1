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
            let dict = newUser.empty()
            userRef.updateChildValues(dict)
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
            let contactRef = database.child("users").queryOrdered(byChild: "isUpdated").queryEqual(toValue: true)
            
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
                        user = ARUser(with: userDict)
                        user.id = arg.key
                        user.coordinate = ARCoordinate(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                        return user
                    }
                    //
                    return user
                })
                
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
            let ref = database.child("users").queryOrdered(byChild: "isUpdated").queryEqual(toValue: true)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                let postDict = snapshot.value as? [String : [String: Any]] ?? [:]
                
                let maped = postDict.map({ (arg) -> ARUser in
                    let user = ARUser(with: arg.value)
                    user.id = arg.key
                    return user
                }).filter({$0.isBlocked == false})
                
                var filtered = maped.filter({$0.id != ARUser.currentUser?.id ?? "" && $0.isUpdated == true && $0.phone != "0000000000104"})
                filtered.shuffle()
                if filtered.count > limit {
                    var array:[ARUser] = [ARUser]()
                    let male = filtered.filter({$0.gender == .male})
                    let female = filtered.filter({$0.gender == .female})
                    if male.count >= 5 {
                        array.append(contentsOf: male[0..<5])
                    } else {
                        array.append(contentsOf: male)
                    }
                    if female.count >= 5 {
                        array.append(contentsOf: female[0..<5])
                    } else {
                        array.append(contentsOf: female)
                    }
                    if array.count < 10 {
                        array.append(contentsOf: filtered.filter({ (user) -> Bool in
                            return !array.contains(where: {$0.id == user.id})
                        })[0...((10-array.count)-1)])
                    }

                    handler?(Array(array).shuffled())
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
