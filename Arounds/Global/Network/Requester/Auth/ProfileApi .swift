//
//  ProfileApi.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SwiftyJSON
import Foundation

class ProfileApi {
    
    func update(user builder: ARUpdateUserBuilder, completion handler:((Error? , Bool?)->Void)?) {
        
        Requester.sendRequestToPath("user", method: .put, parameters:builder.makeDict()) { (error, data, result, statusCode) in
            handler?(error, statusCode == 200)
        }
    }
    
    func updateLocation(user location: ARCoordinate, completion handler:((Error? , Bool?)->Void)?) {
       
        Requester.sendRequestToPath("user", method: .put, parameters:["fireID":ARUser.currentUser?.id ?? "", "lat":location.lat, "lng":location.lng]) { (error, data, result, statusCode) in
            print(error?.localizedDescription ?? "")
            handler?(error, (error == nil))
        }
    }
}
