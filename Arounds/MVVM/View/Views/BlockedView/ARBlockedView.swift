//
//  ARBlockedView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/19/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import MessageUI
import Foundation


class ARBlockedView: UIView {
    
    //MARK: Public vars
    static let shared = ARBlockedView.loadFromNib()
    
    @IBOutlet weak var endDateLabel: UILabel!
    var endDate: Date? {
        didSet{
            if let data = endDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                endDateLabel.text = formatter.string(from: data)
                endDateLabel.isHidden = false
            } else {
                endDateLabel.isHidden = true
            }
        }
    }
    var isPresented: Bool = false
    
    private class func loadFromNib() -> ARBlockedView {
        let instance = UINib.init(nibName: "ARBlockedView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ARBlockedView
        instance.frame = UIScreen.main.bounds
        return instance
    }
    
    func show() {
        isPresented = true
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func hide() {
        isPresented = false
        removeFromSuperview()
    }
    
    @IBAction func didClickSupport(_ sender: UIButton) {
        let body = "Помощь"
        let subject = "Помощь"
        let toRecipients:Array = ["support@arounds.im"]
        
        if MFMailComposeViewController.canSendMail() {
            let emailComposVC = MFMailComposeViewController()
            emailComposVC.mailComposeDelegate = self
            emailComposVC.setMessageBody(body, isHTML: false)
            emailComposVC.setSubject(subject)
            emailComposVC.setToRecipients(toRecipients)
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                topController.present(emailComposVC, animated: true, completion: nil)
            }
            
        }
    }
}

extension ARBlockedView: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
