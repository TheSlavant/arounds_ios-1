//
//  PhoneVerificationViewVodel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SVProgressHUD
import Foundation

protocol PhoneVerificationViewVodeling {
    func verify(code: String)
    func sendCode(phone number: String)
}

class PhoneVerificationViewVodel: PhoneVerificationViewVodeling {
    
    var phoneNumber = ""
    var code = ""
    lazy var phoneAuth = FirebasePhoneAuth()
    var didFillMandatoryCharacters : ((Bool, String) -> Void)?
    
    func verify(code: String) {
        phoneAuth.signIn(with: code)        
    }
    
    func sendCode(phone number: String) {
        phoneAuth.fullNumber = code + number
        phoneAuth.sendCode()
    }
    
}

