//
//  Storage+Data.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/14/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import FirebaseStorage

extension Storage {
    
    static func putData(_ data: Data, completionBlock: ((_ url: URL?, _ errorMessage: String?) -> Void)?) {
        let filename = "\(Date().timeIntervalSince1970)"
        let reference = storage().reference().child("files").child(filename)
        
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
    
}
