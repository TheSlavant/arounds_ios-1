//
//  Storyboards.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/26/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension UIViewController {
    static func instantiate(from storyboard:Storyboards, identifier: String? = nil) -> Self {
        return instantiateFromStoryboard(storyboard.rawValue, identifier)
    }
}

enum Storyboards: String {
    case Initial = "Initial"
    case Reg = "Reg"
    case Home = "Home"
    case Profile = "Profile"
    case Policy = "Policy"
    case ChatList = "ChatList"
    case Map = "Map"
    case Chat = "Chat"
}
