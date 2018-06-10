//
//  ARSegmentedControl.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

enum ARSelectedSegment: Int {
    case first = 1
    case secound = 2
}

class ARSegmentedControl: ARBorderedView {

    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secoundButton: UIButton!
    
    var selected: Int = 1
    private var selectedButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI(name: self.nameOfClass)
        setSelected(segment: .first)
    }
    
    @IBAction func didClickButton(_ sender: UIButton) {
        setSelected(segment: ARSelectedSegment(rawValue: sender.tag)!)
    }
    
    func setSelected(segment: ARSelectedSegment) {
        if let selectedButton = selectedButton {
            deselect(button: selectedButton)
        }
        switch segment {
        case .first:
            select(button: firstButton)
            break
        case .secound:
            select(button: secoundButton)
            break
        }
        
    }
    
    func deselect(button:UIButton) {
        button.isSelected = false
        button.setTitleColor(UIColor.withHex("4F4F6F"), for: .normal)
        button.tintColor = UIColor.withHex("4F4F6F")

    }
    
    func select(button:UIButton) {
        selectedButton = button
        button.isSelected = true
        button.setTitleColor(UIColor.withHex("F94865"), for: .selected)
        button.tintColor = UIColor.withHex("F94865")

    }

    
}
