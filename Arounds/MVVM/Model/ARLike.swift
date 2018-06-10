//
//  ARLike.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Foundation

class ARLike:NSObject, NSCoding {
    var likedUserIds = [String]()
    
    override init() {
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.likedUserIds, forKey: "likedUserIds")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.likedUserIds = (aDecoder.decodeObject(forKey: "likedUserIds") as? [String])!
    }

}
