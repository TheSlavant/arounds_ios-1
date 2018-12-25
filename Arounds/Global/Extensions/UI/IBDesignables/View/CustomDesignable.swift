//
//  CustomDesignable.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class CustomDesignable: UIView {
    
    var view:UIView!
    
    func setupUI(name: String) {
        view = loadFromNib(name: name)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadFromNib(name: String) -> UIView {
        return UINib.init(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        
    }
}
