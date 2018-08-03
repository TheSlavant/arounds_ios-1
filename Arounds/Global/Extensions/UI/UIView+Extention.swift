//
//  UIView+Extention.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension UIView {
    
    func toImage() -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100, height: 100), false, 0)
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }

        return image
    }
    
    func centureOfX() -> CGFloat {
        return frame.origin.x + (frame.size.width / 2)
    }
}
