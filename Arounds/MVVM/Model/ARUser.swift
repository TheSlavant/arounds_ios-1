//
//  ARUser.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SwiftyJSON
import Foundation

struct ARCoordinate {
    var lat: Double
    var lng: Double
}

enum UserGender: Int {
    case male = 1
    case female = 2
}

class ARUser:NSObject, NSCoding {
    var id: String? // fireUserID
    var phone: String?
    var fullName: String?
    var nickName: String?
    var gender: UserGender?
    var birtDay: Date?
    var aboute: String?
    var me: Bool = false
    var isUpdated: Bool = false
    var avatarBase64: String?
    var age: Int?
    var profileLike: ARLike?
    var coordinate: ARCoordinate?
    
    private static var _currentUser:ARUser?
    static var currentUser:ARUser? {
        get {
            if _currentUser == nil {
//                let user = ARUser(with:[String:Any]())
//                user.me = true
//                user.fullName = "Samel Pahlevanyan"
//                user.gender = .male
//                user.age = 23
//                let like = ARLike()
//                user.id = "-LCxtfPXoiDH8QoV7pH3"
//                like.likedUserIds = ["","","","","","","","",""]
//                user.profileLike = like
//                user.nickName = "Samo95"
//                user.isUpdated = true
//                user.phone = "+37498910231"
//                user.aboute = "I am an iOS developer. I live in gyumri, I have a mother, a father and a sister"
//                _currentUser = user
//                return user
//
                if let data = UserDefaults.standard.data(forKey: "current_user") {
                    _currentUser = NSKeyedUnarchiver.unarchiveObject(with: data) as? ARUser
                }
            }
            return _currentUser
        }
        set {
            _currentUser = newValue
            if newValue != nil {
                _currentUser?.save()
            } else {
                _currentUser?.reset()
            }
        }
    }
    
    
    func save() {
        if self != ARUser.currentUser {
            return
        }
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(encodedData, forKey: "current_user")
        UserDefaults.standard.synchronize()
    }
    
    func reset() {
        if self != ARUser.currentUser {
            return
        }
        UserDefaults.standard.removeObject(forKey: "current_user")
        UserDefaults.standard.synchronize()
        
        ARUser.currentUser = nil
    }
    
    override init() {}
    
    init(with dic:[String: Any]) {
        self.phone = dic["phone"] as? String
        self.fullName = dic["fullName"] as? String
        self.nickName = dic["nickname"] as? String
        self.gender = UserGender.init(rawValue: dic["gender"] as? Int ?? 1)
        if let dateInterval = Double(dic["birtDay"] as? String ?? "") {
            self.birtDay = Date.init(timeIntervalSince1970: dateInterval)
        } else {
            self.birtDay = Calendar.current.date(byAdding: .year, value: -14, to: Date())
        }
        

        self.aboute = dic["aboute"] as? String
        self.avatarBase64 = dic["avatar"] as? String
        self.age = dic["age"] as? Int
        self.id = dic["fireID"] as? String
        self.isUpdated = dic["isUpdated"] as? Bool ?? false
    }
    
    init(json: JSON) {
        self.phone = json["phone"].stringValue
        self.fullName = json["fullName"].stringValue
        self.nickName = json["nickname"].stringValue
        self.gender = UserGender.init(rawValue: json["gender"].int ?? 1)
        if let dateInterval = Double(json["birtDay"].stringValue) {
            self.birtDay = Date.init(timeIntervalSince1970: dateInterval)
        } else {
            self.birtDay = Calendar.current.date(byAdding: .year, value: -14, to: Date())
        }
        self.aboute = json["aboute"].stringValue
        self.avatarBase64 = json["avatar"].stringValue
        self.age = json["age"].intValue
        self.id = json["fireID"].stringValue
        self.isUpdated = json["isUpdated"].boolValue
    }
    
    
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.fullName, forKey: "fullName")
        aCoder.encode(self.nickName, forKey: "nickName")
        aCoder.encode(self.gender?.rawValue, forKey: "gender")
        aCoder.encode(self.aboute, forKey: "aboute")
        aCoder.encode(self.birtDay, forKey: "birtDay")
        aCoder.encode(self.me as Any, forKey: "me")
        aCoder.encode(self.avatarBase64, forKey: "avatarBase64")
        aCoder.encode(self.age, forKey: "age")
        aCoder.encode(self.profileLike, forKey: "profileLike")
        aCoder.encode(self.isUpdated as Any, forKey: "isUpdated")
        aCoder.encode(self.id, forKey: "fireID")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.phone = (aDecoder.decodeObject(forKey: "phone") as? String)
        self.fullName = (aDecoder.decodeObject(forKey: "fullName") as? String)
        self.nickName = (aDecoder.decodeObject(forKey: "nickName") as? String)
        self.gender = UserGender(rawValue: (aDecoder.decodeObject(forKey: "gender") as? Int) ?? 1)
        self.aboute = (aDecoder.decodeObject(forKey: "aboute") as? String)
        self.birtDay = (aDecoder.decodeObject(forKey: "birtDay") as? Date)
        self.me = (aDecoder.decodeObject(forKey: "me") as? Bool) ?? false
        self.avatarBase64 = (aDecoder.decodeObject(forKey: "avatarBase64") as? String)
        self.age = (aDecoder.decodeObject(forKey: "age") as? Int)
        self.profileLike = (aDecoder.decodeObject(forKey: "profileLike") as? ARLike)
        self.isUpdated = (aDecoder.decodeObject(forKey: "isUpdated") as? Bool) ?? false
        self.id = (aDecoder.decodeObject(forKey: "fireID") as? String)
    }
    
    
    func getImage() -> UIImage? {
        
        if let base64 = avatarBase64, let data = Data.init(base64Encoded: base64, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func setImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        if let imageData = UIImageJPEGRepresentation(image, 0.4) {
            avatarBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        }
    }
    
}
