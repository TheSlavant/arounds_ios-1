//
//  Algorithms.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class Algorithms {
    
    class func calling(by age:Int) -> String {
        var ageCallimng = ""
        if age <= 20 {
            switch age {
            case 1:
                ageCallimng = "год"
                break
            case 2,3,4:
                ageCallimng = "года"
                break
            case 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20:
                ageCallimng = "лет"
                break
            default: break
            }
        } else {
            switch age % 10 {
            case 1:
                ageCallimng = "год"
                break
            case 2,3,4:
                ageCallimng = "года"
                break
            case 5,6,7,8,9,0:
                ageCallimng = "лет"
                break
            default: break
            }
        }
        return ageCallimng
    }
    
}
