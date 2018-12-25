//
//  Storage+Data.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/14/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import FirebaseStorage
import Kingfisher


extension Storage {
    
    static func putData(_ data: Data, url: String, completionBlock: ((_ url: URL?, _ errorMessage: String?) -> Void)?) {
        let reference = storage().reference().child("files").child(url)
        
        reference.putData(data, metadata: nil, completion: { (metadata, error) in
            if let _ = metadata {
                reference.downloadURL(completion: { (url, error) in
                    completionBlock?(url, error?.localizedDescription)
                })
            } else {
                completionBlock?(nil, error?.localizedDescription)
            }
        })
    }
    
    static func putImage(_ image: UIImage, resize: CGFloat, url: String?, completionBlock: ((_ url: URL?, _ errorMessage: String?) -> Void)?) {
        
        guard let resizedImage = image.resize(toWidth: resize),
            let data = resizedImage.jpegData(compressionQuality: 0.8) else {
                return
        }
        
        let temporaryUrl: String! = url != nil ? url : "\(Date().timeIntervalSince1970)"
//        ImageCache.default.store(resizedImage, forKey: "https://alien.com/\(temporaryUrl).jpg")
        Storage.putData(data, url: temporaryUrl) { (url, errorMessage) in
            completionBlock?(url, errorMessage)
        }
    }
}
