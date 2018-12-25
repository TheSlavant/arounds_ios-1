//
//  FirebasePhoneAuth.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import FirebaseAuth
import Foundation

protocol FirebasePhoneAuthDelegate {
    func resend()
    func sendCode()
    func signIn(with verificationCode: String)
}

class FirebasePhoneAuth: NSObject {
    
    var verification: ((User?, Error?) -> Void)?
    
    var countryCode: String?
    var phonNumber: String?
    var fullNumber: String?
    private var verificationId: String = ""
    
}

extension FirebasePhoneAuth: FirebasePhoneAuthDelegate {
    
    func signIn(with verificationCode: String) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            self.verification?(nil, nil)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { [weak self] (user, error) in
            guard let weakSelf = self else {return}
            
            weakSelf.verification?(user, error)
        }
    }
    
    func resend() {
        _ = sendCode()
    }
    
    func sendCode() {
        PhoneAuthProvider.provider().verifyPhoneNumber(fullNumber ?? "", uiDelegate: self) { (verificationID, error) in
            print(error?.localizedDescription ?? "")
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            UserDefaults.standard.synchronize()
        }
    }
}



extension FirebasePhoneAuth: AuthUIDelegate {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
    }
}
