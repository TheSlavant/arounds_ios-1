//
//  ARTextField.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/28/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARUITextField: ARBorderedView {
    
    
    @IBInspectable var placeholderName: String = "" {
        didSet {
            if buttonTitleLabel != nil {
                buttonTitleLabel.placeholder = placeholderName
            }
        }
    }
    @IBInspectable var imageName: String = ""
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var buttonTitleLabel: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI(name: self.nameOfClass)
        iconImage.image = UIImage(named: imageName)
        buttonTitleLabel.placeholder = placeholderName
    }
}
