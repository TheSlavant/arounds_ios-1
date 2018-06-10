//
//  ARUpdateUserBuilder.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

struct ARUpdateUserBuilder {
    var fireID = ""
    var fullName = ""
    var nicName = ""
    var date:Double = 0
    var gender = 1
    var aboute = ""
    var avatarBase64 = ""
    var phone = ""
    
    func makeDict() -> [String: Any] {
        return ["fullName":fullName,
                "aboute":aboute,
                "nickName":nicName,
                "birtDay":"\(date)",
                "avatar": avatarBase64,
                "phone":phone,
                "gender": 1,
                "fireID":fireID]
    }
}
