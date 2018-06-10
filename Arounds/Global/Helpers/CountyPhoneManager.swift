//
//  CountyPhoneManager.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

struct CountyInfo {
    var pasholder = ""
    var callingCode = ""
    var affineFormat = ""
    var countyCode = ""
    
    init(dic:[String:String]) {
        pasholder = dic["pasholder"] ?? ""
        callingCode = dic["callingCode"] ?? ""
        affineFormat = dic["affineFormat"] ?? ""
        countyCode = dic["countyCode"] ?? ""
    }
}

class CountyPhoneManager {
    var countysInfo: [String: [String:String]]?

    init(with fileName: String) {
        if let path = Bundle.main.path(forResource: "CountyPhones", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: [String:String]] {
            countysInfo = dict
        }
    }
    
    
    func info(with county: String) -> CountyInfo? {
        var countyInfo:CountyInfo? = nil
       
        if let county = countysInfo?[county] {
            countyInfo = CountyInfo(dic: county)
        }
        
        return countyInfo

    }
}
