//
//  UIButton+Extention.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension UIButton {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.contentMode = .scaleAspectFit
    }
    
}
