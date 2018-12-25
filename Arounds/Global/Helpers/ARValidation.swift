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
                               firstName: String,
                               lastName: String,
                               nicName:String,
                               gender:UserGender,
                               date:Date?,
                               aboute:String,
                               avatar:String,
                               phone:String,
                               insta:String) -> (String?, ARUpdateUserBuilder?,[Int]) {
        let fullnameCount = 1
        let nicNameCount = 3
        let abouteCount = 100
        var text = ""
        var intArray = [Int]()
        
        if firstName.count <= fullnameCount {
            text.append("Имя должно быть больше - \(fullnameCount) символа")
            intArray.append(1)
            //            return ("Имя должно быть больше \(fullnameCount) символов", nil)
        }
        
        if lastName.count <= fullnameCount {
            text.append("\nФамилия должна быть больше - \(fullnameCount) символа")
            intArray.append(2)
            //            return ("Фамилия должно быть больше \(fullnameCount) символов", nil)
        }
        
        if nicName.count <= nicNameCount {
            text.append("\nНик профиля должен быть больше - \(nicNameCount) символов")
            intArray.append(3)
            
            //            return ("Ник профиля должно быть больше \(nicNameCount) символов", nil)
        }
//        else if ARValidation.matches(for: "^[A-Za-z0-9]+.$", in: nicName).count == 0 {
//            intArray.append(3)
//            return ("Недопустимый символ в нике", nil, intArray)
//        }
        
        if aboute.count < 20 {
            text.append("\nПоле о себе должно быть больше - \(20) символов")
            intArray.append(4)
            //            return ("Поле о себе должно быть менее \(abouteCount) символов", nil)
        }
        
        if aboute.count > abouteCount {
            text.append("Поле о себе должно быть менее \(abouteCount) символов")
            intArray.append(4)
            //            return ("Поле о себе должно быть менее \(abouteCount) символов", nil)
        }
        
        if insta.count > 0 {
            if (insta.contains("www.") && insta.hasPrefix("https://www.instagram.com") == false) ||  insta.contains(where: { (charactor) -> Bool in
                let value =  (charactor.unicodeScalars.first?.isASCII ?? false) ? (charactor.unicodeScalars.first?.value ?? 0) : 0
                return !((value > 47 && value < 58) || (value > 64 && value < 91) || (value > 96 && value < 123) || (value == 46) || (value == 47) || (value == 58) || (value == 95))
            }) {
                text.append("insta")
                intArray.append(5)
            }
        }
        
//        insta.contains(where: { (charactor) -> Bool in
//            let value =  (charactor.unicodeScalars.first?.isASCII ?? false) ? (charactor.unicodeScalars.first?.value ?? 0) : 0
//            return !((value > 47 && value < 58) || (value > 64 && value < 91) || (value > 96 && value < 123) || (value == 46) || (value == 95))
//        })
        
        if let date = date, (date > Calendar.current.date(byAdding: .year, value: -18, to: Date())! ||
            date < Calendar.current.date(byAdding: .year, value: -99, to: Date())!) {
            text.append("date")
            intArray.append(7)
        }
        
        if text.count > 0 {
            return (text, nil, intArray)
        }

        guard let date = date else {
            intArray.append(6)
            return ("Поле дата рождения должно быть заполнено ", nil, intArray)
            
        }
        
        let userBuilder = ARUpdateUserBuilder.init(fireID: fireID,
                                                   firstName: firstName,
                                                   lastName: lastName,
                                                   fullName: "",
                                                   nicName: nicName,
                                                   date: date.timeIntervalSince1970,
                                                   gender: gender.rawValue,
                                                   aboute: aboute,
                                                   avatarBase64: avatar,
                                                   phone: phone)
        
        return (nil, userBuilder, intArray)
    }
    
    class func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
