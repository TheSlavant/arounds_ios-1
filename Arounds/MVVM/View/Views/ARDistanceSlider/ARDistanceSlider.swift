//
//  ARDistanceSlider.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/15/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARDistanceSlider: ARBorderedView {
    
    var didEndSlide:((CGFloat)-> Void)?

    let minDistance = 500   // metters
    let maxDistance = 3000  // metters
    var selectedDistance: CGFloat = 0 {
        didSet {
            setConstraint(constant: (value * selectedDistance))
            didEndSlide?(selectedDistance)
        }
    }    // in metters
    
    var maxViewWidth: CGFloat {
        get {
            return self.tambSuperView.frame.width
        }
    }
    
    var value: CGFloat {
        get {
            return CGFloat(maxDistance - minDistance) / maxViewWidth
        }
    }
    
    
    @IBOutlet weak var selectableViewleftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tambView: UIView!
    @IBOutlet weak var tambSuperView: ARBorderedView!
    
    var lastPoint: CGPoint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // selectedDistance = CGFloat(minDistance)
        self.setupUI(name: self.nameOfClass)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch: UITouch = touches.first, touch.view == tambView {
            lastPoint = touch.location(in: tambView)
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch: UITouch = touches.first, touch.view == tambView {
            let newLocation = touch.location(in: tambView)
          
            if let lastPoint = lastPoint {
                
                let a = lastPoint.x - newLocation.x
                setConstraint(constant: a)
            }
        }

    }
    
    func setConstraint(constant: CGFloat) {
        if selectableViewleftConstraint.constant - constant <= 0 {
            selectableViewleftConstraint.constant -= 0
        } else if selectableViewleftConstraint.constant - constant >= tambSuperView.frame.width - tambView.frame.width {
            selectableViewleftConstraint.constant = tambSuperView.frame.width - tambView.frame.width
        } else {
            selectableViewleftConstraint.constant -= constant
        }
        layoutIfNeeded()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = nil

        if selectableViewleftConstraint.constant >= (maxViewWidth - (tambView.frame.width + 20)) {
            selectedDistance = CGFloat(maxDistance)
            return
        }
        selectedDistance = (selectableViewleftConstraint.constant * value) + CGFloat(minDistance)

    }
}
