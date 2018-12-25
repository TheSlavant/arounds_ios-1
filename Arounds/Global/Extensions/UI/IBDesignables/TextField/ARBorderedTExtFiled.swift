//
//  ARBorderedTExtFiled.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

@IBDesignable
class ARBorderedTExtFiled: ARTextField {
    
    @IBInspectable var rounded: Bool = false {
        didSet {
            layer.cornerRadius = frame.size.height/2
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var bgColor: UIColor? = nil
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var hightlightBGColor: UIColor?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if rounded {
            cornerRadius = frame.size.height/2
        }
    }
    
}

