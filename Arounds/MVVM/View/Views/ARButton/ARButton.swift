//
//  ARButton.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/4/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARButton: ARBorderedView {

    var didClick: ((ARButton) -> Void)?

    @IBInspectable var titleName: String = "" {
        didSet {
            if buttonTitleLabel != nil {
                buttonTitleLabel.text = titleName
            }
        }
    }
    @IBInspectable var imageName: String = ""
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var buttonTitleLabel: UILabel!
    
    @IBAction func didClickButton(_ sender: UIButton) {
        didClick?(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI(name: self.nameOfClass)
        iconImage.image = UIImage(named: imageName)
        buttonTitleLabel.text = titleName
    }

}
