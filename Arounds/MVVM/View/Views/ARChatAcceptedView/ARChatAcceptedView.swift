//
//  ARChatAcceptedView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/6/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARChatAcceptedView: UIView {
  
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
 
    var didClickAccept:((UIButton)-> Void)?
    var didClickDecline:((UIButton)-> Void)?

    class func loadFromNib() -> ARChatAcceptedView {
        let instance = UINib.init(nibName: "ARChatAcceptedView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ARChatAcceptedView
        instance.frame.size.width = UIScreen.main.bounds.size.width
        instance.acceptButton.imageView?.contentMode = .scaleAspectFit
        instance.declineButton.imageView?.contentMode = .scaleAspectFit

        return instance
    }
    
    @IBAction func declineButtonClick(_ sender: UIButton) {
        didClickDecline?(sender)
    }
    
    @IBAction func acceptButtonClick(_ sender: UIButton) {
        didClickAccept?(sender)
    }
    
    func close() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            print(Thread.isMainThread)
            self.didClickAccept = nil
            self.didClickDecline = nil
            self.removeAllSubviews()
            self.alpha = 0
            self.isHidden = true
            self.removeFromSuperview()
        }
        
    }
}
