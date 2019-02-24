//
//  MapViewModel.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import CoreLocation
import Firebase
import Foundation

class MapViewModel: MapViewModeling {
    var nearestUser = [ARUser]()
    
    func getUsers(by filter: ARUserFilter, completion handler:(([ARUser])->Void)?) {
        nearestUser(radius: filter.distance) { (users) in
            Database.Users.users(by: users, completion: {[weak self] (users) in
                guard let weakSelf = self else {
                    handler?([ARUser]())
                    return
                }
                weakSelf.nearestUser = weakSelf.filtered(users: users, filter: filter)
                handler?(weakSelf.nearestUser)
            })
        }
    }
    
    func nearestUser(radius: CGFloat, completion handler:(([(String , CLLocation)])->Void)?)  {
        if let userID = ARUser.currentUser?.id, let location = ARUser.currentUser?.coordinate {
            Database.GeoLocation.users(in: location, radius: radius, userID: userID) { (users) in
                handler?(users)
            }
        }
    }
    
    func filtered(users: [ARUser], filter: ARUserFilter) -> [ARUser] {
        return users.filter({ (user) -> Bool in
          
            if user.id == ARUser.currentUser?.id ?? "" {
                return false
            }
            
            // filter by gender
            if (filter.female == false && user.gender == .female) ||
                (filter.male == false && user.gender == .male)
            {
                return false
            }
            //
            // filter by age
            
            let components = Calendar.current.dateComponents([.year], from: user.birtDay ?? Date(), to: Date())
            if components.year ?? 0 < filter.ageStart ||
                components.year ?? 0 > filter.ageEnd {
                return false
            }
            //
            return true
        })
    }
}




