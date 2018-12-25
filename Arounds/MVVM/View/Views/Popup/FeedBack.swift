//
//  FeedBack.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 8/6/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FeedBack: UIView {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var textView: ARTextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: ARGradientedButton!
    @IBOutlet var stars: [UIButton]!
    var selectedStar = 0
    
    class func loadFromNib() -> FeedBack {
        let instance = UINib.init(nibName: "FeedBack", bundle: nil).instantiate(withOwner: self, options: nil).first as! FeedBack
        instance.frame = UIScreen.main.bounds
        instance.textView.didClickText = { text in
            instance.sendButtonEnabled(text: text)
        }
        instance.textView.didClickText?(instance.textView.textView.text)

        return instance
    }

    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    var keyboardIsOpened = false
    @objc func keyboardDidShow(notification: NSNotification) {
        if keyboardIsOpened == true {return}
        keyboardIsOpened = true
        UIView.animate(withDuration: 0.2) {
            self.bottomConstraint.constant = 0 - 150
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        keyboardIsOpened = false
        UIView.animate(withDuration: 0.2) {
            
            self.bottomConstraint.constant = 0
            self.layoutIfNeeded()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.dropShadow(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), offSet: CGSize(width: -2.0, height: 2.0), view: self.shadowView)

    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.3, offSet: CGSize, radius: CGFloat = 7, scale: Bool = true, view: UIView) {
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
        
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func acceptButton(_ sender: UIButton) {
        if textView.textView.text.count == 0 {
            sendButtonEnabled(text: textView.textView.text)
            return
        }
        
        Database.database().reference().child("feedback").childByAutoId().updateChildValues(["star": selectedStar,
                                                                                             "text": textView.textView.text,
                                                                                             "senderId": ARUser.currentUser?.id ?? "",
                                                                                             "date": [".sv":"timestamp"]])
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0
        }) { (finish) in
            self.removeFromSuperview()
        }
        
    }
    
    @IBAction func starButton(_ sender: UIButton) {
        selectedStar = sender.tag
        
        for i in 0..<selectedStar {
            let button = stars[i]
            button.tintColor = UIColor.withHex("FFD870")
        }
        
        for i in selectedStar..<stars.count {
            let button = stars[i]
            button.tintColor = UIColor.withHex("F5F5F5")
        }
        sendButtonEnabled(text: textView.textView.text)
    }
    
    func sendButtonEnabled(text: String) {
        if selectedStar == 0 {
            self.sendButton.isEnabled = false
            self.sendButton.startColor = UIColor.withHex("88889C")
            self.sendButton.endColor = UIColor.withHex("88889C")
            return
        }
        self.sendButton.isEnabled = !text.isEmpty
        self.sendButton.startColor = UIColor.withHex(!text.isEmpty == true ? "FF3FB4" : "88889C" )
        self.sendButton.endColor = UIColor.withHex(!text.isEmpty == true ? "F35119" : "88889C" )
//        shadowButton.isHidden = !self.sendButton.isEnabled
        
    }


}
