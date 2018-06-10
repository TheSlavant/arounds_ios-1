//
//  ARGradientedButton.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/28/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

@IBDesignable
class ARGradientedButton: ARBorderedButton {
    
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var isBorder:     Bool = false { didSet { border() }}

    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    var shape = CAShapeLayer()

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    func border() {
        if isBorder {
            gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
            shape.lineWidth = borderWidth
            shape.path = UIBezierPath(rect: self.bounds).cgPath
            shape.fillColor = UIColor.clear.cgColor
            gradientLayer.mask = shape
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        } else {
            gradientLayer.mask = nil
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
        border()
    }
}
