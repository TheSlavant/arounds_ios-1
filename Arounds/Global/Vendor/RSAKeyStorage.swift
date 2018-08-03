//
//  RSAKeyStorage.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import SwiftyRSA

class RSAKeyStorage {
    
    let userId: String
    
    private var privateKeyTag: String {
        return "\(self.userId)-private"
    }
    
    private var publicKeyTag: String {
        return "\(self.userId)-public"
    }
    
    init(userId: String) {
        self.userId = userId
    }
    
    var myPublicKey: PublicKey? {
        guard let derKey = try? SwKeyStore.getKey(publicKeyTag),
            let pub = try? PublicKey(pemEncoded: derKey) else {
                return nil
        }
        
        return pub
    }
    
    var myPrivateKey: PrivateKey? {
        guard let derKey = try? SwKeyStore.getKey(privateKeyTag),
            let priv = try? PrivateKey(pemEncoded: derKey) else {
                return nil
        }
        
        return priv
    }
    
    func regenerateKeys() -> (publicKey: String, privateKey: String) {
        let (privKey, pubKey) = try! CC.RSA.generateKeyPair(512)
        
        let publicPEM = SwKeyConvert.PublicKey.derToPKCS1PEM(pubKey)
        let privatePEM = SwKeyConvert.PrivateKey.derToPKCS1PEM(privKey)
        
        try? SwKeyStore.upsertKey(publicPEM, keyTag: publicKeyTag, options: [kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly])
        try? SwKeyStore.upsertKey(privatePEM, keyTag: self.privateKeyTag, options: [kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly])
        
        return (publicPEM, privatePEM)
    }
    
}
