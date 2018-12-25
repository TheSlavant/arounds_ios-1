//
//  ARGradientedView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/18/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

@IBDesignable
class ARShadowedView: ARBorderedView {
    
//    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.dropShadow(color: .black, opacity: 0.5, offSet: CGSize(width: -1, height: 1), radius: 10, scale: true)

    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
