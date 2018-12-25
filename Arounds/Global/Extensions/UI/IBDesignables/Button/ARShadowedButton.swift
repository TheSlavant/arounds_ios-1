//
//  ARShadowedButton.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/28/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

@IBDesignable
class ARShadowedButton: ARGradientedButton {
  
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
//            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2
            
            layer.insertSublayer(shadowLayer, at: 0)
//            layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }

   
}
