//
//  RSA.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import SwiftyRSA

final class RSA {
    
    static let shared = RSA()
    
    let keyStorage = RSAKeyStorage(userId: ARUser.currentUser?.id ?? "")

    private init() {}
    
    private var publicKeys: [String: PublicKey] = [:]
    
    fileprivate func getPublicKey(_ publicKey: String) -> PublicKey? {
        if self.publicKeys[publicKey] == nil,
            let pub = try? PublicKey(pemEncoded: publicKey) {
            self.publicKeys[publicKey] = pub
        }
        
        return self.publicKeys[publicKey]
    }

}

// MARK: - Encrypt
extension RSA {

    func encrypt(text: String, publicKey: String) -> String? {
        guard let data = text.data(using: .unicode) else {
            return nil
        }

        return encryptData(data, publicKey: publicKey)?.base64String
    }

    func encrypt(data: Data, publicKey: String) -> Data? {
        return encryptData(data, publicKey: publicKey)?.data
    }

    func encrypt(data: Data, publicKey: String, callback: @escaping ((Data?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let encryptedData: Data? = self.encrypt(data: data, publicKey: publicKey)
            DispatchQueue.main.async {
                callback(encryptedData)
            }
        }
    }

   private func encryptData(_ data: Data, publicKey: String) -> EncryptedMessage? {
        let clearMessage = ClearMessage(data: data)

        guard let pub = getPublicKey(publicKey),
            let encrypted = try? clearMessage.encrypted(with: pub, padding: .PKCS1) else {
                return nil
        }

        return encrypted
    }

}

// MARK: - Decrypt
extension RSA {

    func decrypt(text: String) -> String? {
        guard let data =  Data(base64Encoded: text),
            let decryptedData = decrypt(data: data) else {
                return nil
        }

        return String(data: decryptedData, encoding: .unicode)
    }

    func dectypt(data: Data, callback: @escaping ((Data?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let decryptedData: Data? = self.decrypt(data: data)
            DispatchQueue.main.async {
                callback(decryptedData)
            }
        }
    }

    func decrypt(data: Data) -> Data? {
        let message = EncryptedMessage(data: data)

        guard let priv = self.keyStorage.myPrivateKey,
            let decrypted = try? message.decrypted(with: priv, padding: .PKCS1)
            else {
                return nil
        }

        return decrypted.data
    }

}
