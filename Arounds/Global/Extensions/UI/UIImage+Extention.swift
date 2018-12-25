//
//  UIImage+Extention.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/30/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage(width: CGFloat) -> UIImage {
        
        let scale = width / self.size.width
        let newHeight = self.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: newHeight))
        self.draw(in: CGRect.init(x: 0, y: 0, width: width, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }

}
