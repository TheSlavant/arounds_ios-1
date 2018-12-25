//
//  UIView+Subview.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/8/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension UIView {
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.flatMap { $0.superview(of: type) }
    }
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.flatMap { $0 as? T ?? $0.subview(of: type) }.first
    }
    
    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}
