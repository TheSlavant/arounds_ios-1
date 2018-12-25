//
//  ARSocial.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

//enum SocialURL: String {
//    var vk = "https://vk.com/"
//    var fb = ""
//    var insta = ""
//    var twiter = ""

//}

enum SocialPrafix : String {
    case vk = "https://vk.com/"
    case fb = "https://www.facebook.com"
    case insta = "https://www.instagram.com/"
    case twiter = "https://twitter.com/"
}

class ARSocial {
    var vk = ""
    var fb = ""
    var insta = ""
    var twiter = ""

    func toDict() -> [String:String] {
        
        return [ "vk" : vk.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                 "fb" : fb.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                 "insta" : insta.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                 "twiter" : twiter.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)]
    }
    
    init(dict: [String:String]) {
        vk = dict["vk"] ?? ""
        fb = dict["fb"] ?? ""
        insta = dict["insta"] ?? ""
        twiter = dict["twiter"] ?? ""
    }
    
    func save() {
        UserDefaults.standard.set(["vk":vk,"fb":fb,"insta":insta,"twiter":twiter,], forKey: "user_social")
        UserDefaults.standard.synchronize()
    }
    
    static func rebase() -> ARSocial? {
        if let dict = UserDefaults.standard.value(forKey: "user_social") as? [String: String] {
            return ARSocial.init(dict: dict)
        }
        return nil
    }
    

}
