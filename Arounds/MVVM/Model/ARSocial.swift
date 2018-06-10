//
//  ARSocial.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class ARSocial {
    var vk = ""
    var fb = ""
    var insta = ""
    var twiter = ""

    func toDict() -> [String:String] {
        return [ "vk" : vk,
                 "fb" : fb,
                 "insta" : insta,
                 "twiter" : twiter]
    }
    
    init(dict: [String:String]) {
        vk = dict["vk"] ?? ""
        fb = dict["fb"] ?? ""
        insta = dict["insta"] ?? ""
        twiter = dict["twiter"] ?? ""
    }
    
}
