//
//  ARDistanceSlider.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/15/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARDistanceSlider: ARBorderedView {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    var state = 1
    var didEndSlide:((CGFloat)-> Void)?

    let minDistance = 500   // metters
    let maxDistance = 5000  // metters
    var selectedDistance: CGFloat = 0 {
        didSet {
            if selectedDistance == 500 {
                slide(as: 1)
            } else if selectedDistance == 1000 {
                slide(as: 2)
            } else if selectedDistance == 2000 {
                slide(as: 3)
            } else if selectedDistance == 5000 {
                slide(as: 4)
            }
//            setConstraint(constant: (value * selectedDistance))
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
        
//        if let touch: UITouch = touches.first, touch.view == tambView {
//            let newLocation = touch.location(in: tambView)
//
//            if let lastPoint = lastPoint {
//
//                let a = lastPoint.x - newLocation.x
//                setConstraint(constant: a)
//            }
//        }
    }
    
    func setConstraint(constant: CGFloat) {
//        if selectableViewleftConstraint.constant - constant <= 0 {
//            selectableViewleftConstraint.constant -= 0
//        } else if selectableViewleftConstraint.constant - constant >= tambSuperView.frame.width - tambView.frame.width {
//            selectableViewleftConstraint.constant = tambSuperView.frame.width - tambView.frame.width
//        } else {
//            selectableViewleftConstraint.constant -= constant
//        }

        UIView.animate(withDuration: 0.2, animations: {
            self.selectableViewleftConstraint.constant = constant
            self.layoutIfNeeded()

        }) { (finish) in
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        lastPoint = nil
//
//        if selectableViewleftConstraint.constant >= (maxViewWidth - (tambView.frame.width + 20)) {
//            selectedDistance = CGFloat(maxDistance)
//            return
//        }
//        selectedDistance = (selectableViewleftConstraint.constant * value) + CGFloat(minDistance)

    }
    
    @IBAction func didClickButton(_ sender: UIButton) {
        slide(as: sender.tag)
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        if state == 4 {return}
        state += 1
        slide(as: state)
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        if state == 1 {return}
        state -= 1
        slide(as: state)
    }
    
    func slide(as tag: Int) {
        
        var value:CGFloat = 0
        switch tag {
        case 1:
            value = 0
            self.didEndSlide?(CGFloat(500))
            break
        case 2:
            value = label2.centureOfX() - ((tambView.frame.width/2) + 20)
            self.didEndSlide?(CGFloat(1000))
            break
        case 3:
            value = label3.centureOfX() - ((tambView.frame.width/2) + 20)
            self.didEndSlide?(CGFloat(2000))
            break
        case 4:
            value = maxViewWidth - tambView.frame.width
            self.didEndSlide?(CGFloat(5000))
            break
        default: break
            
        }
        state = tag
        setConstraint(constant: value)
        
    }
    
}
