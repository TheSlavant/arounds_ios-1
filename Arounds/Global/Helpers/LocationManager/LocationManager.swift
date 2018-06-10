//
//  CountyPhoneManager.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import CoreLocation
import Foundation

protocol LocationManagerDelegate {
    func userCurrentLocation(location :CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locManager: CLLocationManager!
    var locationDelegate: LocationManagerDelegate? = nil
    private override init(){}
    static let shared:LocationManager = {
        let sharedManager = LocationManager()
        sharedManager.locManager = CLLocationManager()
        sharedManager.locManager.delegate = sharedManager
        sharedManager.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return sharedManager
    }()
    
    
    // MARK: Public func
    func allowRequest() {
        LocationManager.shared.locManager.requestWhenInUseAuthorization()
        LocationManager.shared.locManager.requestAlwaysAuthorization()
        LocationManager.shared.locManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            ARUser.currentUser?.coordinate = ARCoordinate(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            self.locationDelegate?.userCurrentLocation(location: location)
        }
    }
    
    
}



