//
//  ARDistanceSlider.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/15/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARDistanceSlider: ARBorderedView {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endLessImageVIew: UIImageView!
    @IBOutlet weak var lable5: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    var state = 1
    var didEndSlide:((CGFloat)-> Void)?
    var inProgress:Bool = false
    let minDistance = 500   // metters
    let maxDistance = 5000  // metters
    var lastSelectedDistance: CGFloat = 0
    var lastTag: Int = 0
    var selectedDistance: CGFloat = 0 {
        didSet {
            if lastSelectedDistance == selectedDistance {return}
            lastSelectedDistance = selectedDistance
            layoutIfNeeded()
            if selectedDistance == 500 {
                slide(as: 1, notify: false)
            } else if selectedDistance == 1000 {
                slide(as: 2, notify: false)
            } else if selectedDistance == 2000 {
                slide(as: 3, notify: false)
            } else if selectedDistance == 5000 {
                slide(as: 4, notify: false)
            } else if selectedDistance == 5000000 {
                slide(as: 5, notify: false)
            }
//            setConstraint(constant: (value * selectedDistance))
        }
    }    // in metters
    
    func indexToRadius(index:Int) -> CGFloat {
        switch index {
        case 1:
            return 500
        case 2:
            return 1000
        case 3:
            return 2000
        case 4:
            return 5000
        case 5:
            return 5000000
        default:
            return 0
        }
    }
    
    func radiusToIndex(redius:Int) -> Int {
        switch redius {
        case 500:
            return 1
        case 1000:
            return 2
        case 2000:
            return 3
        case 5000:
            return 4
        case 5000000:
            return 5
        default:
            return 0
        }
    }

    
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
    
    func slide(as tag: Int, notify: Bool = true) {
        if inProgress {return}
        if lastTag == tag {return}

        var value:CGFloat = 0
        var radius:CGFloat = 0
        switch tag {
        case 1:
            value = 0
            radius = CGFloat(500)
            break
        case 2:
            value = label2.centureOfX() - ((tambView.frame.width/2) + 20)
            radius = CGFloat(1000)
            break
        case 3:
            value = label3.centureOfX() - ((tambView.frame.width/2) + 20)
            radius = CGFloat(2000)
            break
        case 4:
            value = label4.centureOfX() - ((tambView.frame.width/2) + 20)
            radius = CGFloat(5000)
            break
        case 5:
            value = maxViewWidth - tambView.frame.width
            radius = CGFloat(1500000)
            break
        default: break
        }
        lastTag = tag
        if notify {
            inProgress = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                self?.inProgress = false
            }
            self.didEndSlide?(radius)
        }
        state = tag
        setConstraint(constant: value)
        

    }
    
}
