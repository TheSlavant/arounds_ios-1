//
//  DatabaseAccess.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase

protocol DatabaseAccess {
}

extension DatabaseAccess {
    
    static var database: DatabaseReference {
        return Database.database().reference()
    }
    
}
