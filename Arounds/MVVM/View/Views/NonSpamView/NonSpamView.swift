//
//  NonSpamView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/27/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class NonSpamView: UIView {
    
    var didCloseSpamView:(()-> Void)?

    class func loadFromNib() -> NonSpamView {
        let sharedView = UINib.init(nibName: "NonSpamView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! NonSpamView
        sharedView.frame = UIScreen.main.bounds
        return sharedView
    }
    
    
    func show() {
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(self)
        }
    }
    
    @IBAction func didAgree(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "kAgreeTermsOfUse")
        UserDefaults.standard.synchronize()
        didCloseSpamView?()
        self.removeFromSuperview()
    }
    
}
