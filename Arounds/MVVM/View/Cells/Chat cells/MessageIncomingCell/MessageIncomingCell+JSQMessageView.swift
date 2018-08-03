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

fileprivate let typingView = UserTypingView.loadFromNib()
var isTyping:Bool = false

extension MessageIncomingCell: MessageCell {
    
    func updateView(with message: JSQMessage) {
        self.type = message.type
        isTyping = false
        typingView.removeFromSuperview()
        typingView.isHidden = true
        typingView.stop = true
        if message.isMediaMessage == true, let url = message.attachmentURL {
            bubleImageView.isHidden = false
            bubleImageView.layer.cornerRadius = 7
            bubleImageView.clipsToBounds = true
            
            bubleImageView.kf.setImage(with: url)
            bubleImageView.contentMode = .scaleAspectFill
        } else if message.type == .typing {
            isTyping = true
            typingView.isHidden = false
            typingView.frame = self.textView.bounds
            typingView.backgroundColor = .clear
            
            typingView.frame.origin = CGPoint.zero
            typingView.frame.size = CGSize.init(width: (UIScreen.main.bounds.width / 2.4), height: 60)
            textView.frame.size = typingView.frame.size
            self.messageBubbleContainerView.frame.size = typingView.frame.size
            self.messageBubbleContainerView.addSubview(typingView)
            //            self.textView.bounds.size = a.frame.size
            //            self.textView.addSubview(a)
            //            a.layoutIfNeeded()
            
            typingView.selectedIndex = 0
            typingView.stop = false
            typingView.start(dilay: 0.1)
//            self.textView.textColor = .white
        } else {
            bubleImageView.isHidden = true
            self.textView.text = message.text
            self.textView.textColor = UIColor.withHex("88889C")
        }
        
        if !message.isMediaMessage {
            if message.type != .typing {
                DispatchQueue.main.async {
                    self.textView.sizeToFit()
                }
            }
            textView.isSelectable = false
            textView.isUserInteractionEnabled = false
            bubleImageView.isUserInteractionEnabled = true
            gestureRecognizers?.forEach({removeGestureRecognizer($0)})
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.jsq_handleAvatarTapGesture)))
        } else {
            textView.isSelectable = true
            textView.isUserInteractionEnabled = true
            
            bubleImageView.isUserInteractionEnabled = true
            gestureRecognizers?.forEach({removeGestureRecognizer($0)})
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.jsq_handleTapGesture)))
        }
        
        self.cellTopLabel.text = "@" + (reciver?.nickName ?? "")
        self.cellTopLabel.textColor = UIColor.withHex("4F4F6F")
        self.cellTopLabel.font = UIFont(name: "MontserratAlternates-Bold", size: 12)!
        self.cellTopLabel.textAlignment = .left
        self.timeLabel.text = getFormattedDate(for: message)
        
        self.textView.layer.cornerRadius = 5
        self.textView.backgroundColor = UIColor.white
        self.timeLabel.textColor = UIColor.withHex("88889C")
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height/2
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.contentMode = .scaleAspectFill
        
        if isTyping == true {return}
        
        
        DispatchQueue.main.async {
            self.dropShadow(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), opacity: 0.3, offSet: CGSize(width: -2.0, height: 2.0), radius: 5, scale: true, view: self.type == .typing ? typingView : self.textView)
        }
        
    }
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        self.textView.sizeToFit()
    //    }
    
    @objc func jsq_handleTapGesture(_ tap: UITapGestureRecognizer) {
        
        if handleAvatarTapGesture(tap: tap) == true {
            return
        }
        
        let vc = UIStoryboard.init(name: "ImageView", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
        vc.image = bubleImageView.image
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(vc, animated: true, completion: nil)
    }
    
    
    @objc func jsq_handleAvatarTapGesture(_ tap: UITapGestureRecognizer) {
        _ = handleAvatarTapGesture(tap: tap)
    }
    
    func handleAvatarTapGesture(tap: UITapGestureRecognizer) -> Bool {
        let view = tap.view
        let loc = tap.location(in: view)
        let subview = view?.hitTest(loc, with: nil) // note: it is a `UIView?`
        
        if subview?.frame.size == avatarImageView.frame.size {
            let nv = ((UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarVC)?.selectedViewController as? UINavigationController)
            let a = nv?.viewControllers.first?.presentedViewController as? OneToOneVC
            
            let vc = ProfileVC.instantiate(from: .Profile)
            vc.isFromChat = true
            vc.viewModel = OtherProfileViewModel.init(with: a!.viewModel.recever!)
            a?.present(vc, animated: true, completion: nil)
            //            nv?.pushViewController(vc, animated: true)
            return true
        }
        return false
    }
    
    
    func shadowClean(view: UIView) {
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 0
        
        view.layer.shadowPath = UIBezierPath.init().cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = 0
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.type != .typing {
            self.textView.sizeToFit()
            
        }
        //        print("draw")
    }

}
