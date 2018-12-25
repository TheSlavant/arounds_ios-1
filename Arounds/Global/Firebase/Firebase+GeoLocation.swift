//
//  Firebase+GeoLocation.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import GeoFire
import CoreLocation
import Firebase

fileprivate let locations = "locations"
extension Database {
    
    enum GeoLocation: DatabaseAccess {
        
        static func updateLocation(in location:ARCoordinate, userID: String) {
            let isOnline = UserDefaults.standard.bool(forKey: "isOnline")
            let geofireRef = database.child(locations)
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire.setLocation(CLLocation(latitude: isOnline ? location.lat : 0, longitude: isOnline ? location.lng : 0), forKey: userID)
        }
        
        static func users(in location:ARCoordinate, radius:Int, userID: String, completion handler:(([(key: String, location: CLLocation)])->Void)?) {
            let geofireRef = database.child(locations)
            let geoFire = GeoFire(firebaseRef: geofireRef)
            let center = CLLocation(latitude: location.lat, longitude: location.lng)
            let circleQuery = geoFire.query(at: center, withRadius: Double(Double(radius) / 1000))

            var array = [(key: String, location: CLLocation)]()
            circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in

                if !array.contains(where: { (extKey, extLocation) -> Bool in
                    return extKey == key || key == userID
                }) {
                    array.append((key: key, location: location))
                }
            })
            
            circleQuery.observeReady {
                handler?(array)
            }
        }
    }
    
}
