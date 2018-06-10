//
//  LocationSharingManager.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import Foundation

class LocationSharingManager {
    
    var timer: Timer?
    
    
    func start(interval:Double) {
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer) in
            if let user = ARUser.currentUser,
                let location = user.coordinate,
                let userId = user.id
            {
                Database.GeoLocation.updateLocation(in: location, userID: userId)
//                ProfileApi().updateLocation(user: location, completion: { (error, success) in
//
//                })
            }

        })
    }
}
