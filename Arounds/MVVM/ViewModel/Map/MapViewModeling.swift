//
//  MapViewModeling.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import CoreLocation
import Foundation

protocol MapViewModeling {
    func getUsers(by filter: ARUserFilter, completion handler:(([ARUser])->Void)?)
    
}
