//
//  MessageIncomingCell+a.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Kingfisher
import UIKit
import JSQMessagesViewController.JSQMessage

extension MessageOutgoingCell: MessageCell {
    
    func updateView(with message: JSQMessage) {
        
        statusImage.tintColor = UIColor.withHex("88889C")
        let seen = message.status == .seen
        statusImage.isHidden = !seen
//        UIView.animate(withDuration: 0.01) {
            self.statusIconWidth.constant = seen ? 14 : 0
            self.dateRightPading.constant = seen ? 10 : 0
            self.layoutIfNeeded()
//        }

        if message.isMediaMessage == true, let url = message.attachmentURL {
            bubleImageView.isHidden = false
            bubleImageView.layer.cornerRadius = 7
            bubleImageView.clipsToBounds = true
            bubleImageView.setImage(with: url)
            bubleImageView.contentMode = .scaleAspectFill
        } else {
            bubleImageView.isHidden = true
            self.textView.text = message.text
        }
        
        
        if !message.isMediaMessage {
            textView.isSelectable = false
            textView.isUserInteractionEnabled = false

            bubleImageView.isUserInteractionEnabled = true
            gestureRecognizers?.forEach({removeGestureRecognizer($0)})
        } else {
            textView.isSelectable = true
            textView.isUserInteractionEnabled = true

            bubleImageView.isUserInteractionEnabled = true
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.jsq_handleTapGesture)))
        }

        if message.type == .typing {
            statusImage.isHidden = true
        }
        
        self.cellTopLabel.text = "@" + message.senderDisplayName
        self.cellTopLabel.textColor = UIColor.withHex("4F4F6F")
        self.cellTopLabel.font = UIFont(name: "MontserratAlternates-Bold", size: 12)!
        self.cellTopLabel.textAlignment = .right
        self.timeLabel.text = getFormattedDate(for: message)
        self.textView.textColor = UIColor.withHex("88889C")

        
        self.textView.layer.cornerRadius = 7
        self.textView.backgroundColor = UIColor.white
        self.timeLabel.textColor = UIColor.withHex("88889C")
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height/2
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.contentMode = .scaleAspectFill

        DispatchQueue.main.async {
            self.dropShadow(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), opacity: 0.3, offSet: CGSize(width: -2.0, height: 2.0), radius: 5, scale: true, view: self.textView)

        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        }
        self.layoutIfNeeded()
        self.setNeedsDisplay()
    }
    
    @objc func jsq_handleTapGesture(_ tap: UITapGestureRecognizer) {
        let vc = UIStoryboard.init(name: "ImageView", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
        vc.image = bubleImageView.image
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(vc, animated: true, completion: nil)
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
//        print("layoutSubviews")

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            self.textView.sizeToFit()
//        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.textView.sizeToFit()
//        print("draw")
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true, view: UIView) {
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
        
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

}
