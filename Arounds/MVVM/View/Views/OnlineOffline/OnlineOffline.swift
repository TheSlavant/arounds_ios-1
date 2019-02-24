//
//  OnlineOffline.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 9/4/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class OnlineOffline: UIView {
    
    @IBOutlet weak var animationConsrataint: NSLayoutConstraint!
    @IBOutlet weak var animationImage: UIImageView!
    @IBOutlet weak var licationIcon: UIImageView!
    @IBOutlet weak var tapButton: UIButton!

    var didSwitchOnline: ((Bool) -> Void)?

    var isOnline: Bool = true {
        didSet {
            licationIcon.isHighlighted = isOnline
            if isOnline {
                endAnimation()
            } else {
                startAnimation()
            }
            didSwitchOnline?(isOnline)
        }
    }
    
    class func loadFromNib() -> OnlineOffline {
        let instance = UINib.init(nibName: "OnlineOffline", bundle: nil).instantiate(withOwner: self, options: nil).first as! OnlineOffline
        instance.frame.origin.y = 75
        instance.frame.origin.x = 10

        return instance
        
    }
    
    func startAnimation() {
        animationImage.isHidden = false
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: { [weak self] in
            
            self?.animationConsrataint.constant = 48.5
            self?.layoutIfNeeded()
        }, completion: nil)

    }
    
    func endAnimation() {
        animationImage.isHidden = true
        self.layer.removeAllAnimations()
    }

    @IBAction func didClickButton(_ sender: UIButton) {
        self.tapButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tapButton.isEnabled = true
        }
        isOnline = !isOnline
    }
    

    
}
