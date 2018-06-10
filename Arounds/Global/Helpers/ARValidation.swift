//
//  ARValidation.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class ARValidation {
    
    class func validateUpdated(fields fireID:String,
                               fullName:String,
                               nicName:String,
                               gender:UserGender,
                               date:Date?,
                               aboute:String,
                               avatar:String,
                               phone:String) -> (String?, ARUpdateUserBuilder?) {
        let fullnameCount = 5
        let nicNameCount = 5
        let abouteCount = 100
        
        if fullName.count <= fullnameCount {
            return ("Имя и фамилия должно быть больше \(fullnameCount) символов", nil)
        }
        
        if nicName.count <= nicNameCount {
            return ("Ник профиля должно быть больше \(nicNameCount) символов", nil)
        }
        
        if aboute.count > abouteCount {
            return ("Поле о себе должно быть менее \(abouteCount) символов", nil)
        }
        
        guard let date = date else {
            return ("Поле дата рождения должно быть заполнено ", nil)
        }
        
        
        let userBuilder = ARUpdateUserBuilder.init(fireID: fireID,
                                                   fullName: fullName,
                                                   nicName: nicName,
                                                   date: date.timeIntervalSince1970,
                                                   gender: gender.hashValue,
                                                   aboute: aboute,
                                                   avatarBase64: avatar,
                                                   phone: phone)
        
        return (nil, userBuilder)
    }
}
