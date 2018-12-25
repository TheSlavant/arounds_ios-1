//
//  ARChatNavigationView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/6/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARChatNavigationView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var didClickBack:((UIButton)-> Void)?
    var didClickAudio:((UIButton)-> Void)?
    var didClickVideo:((UIButton)-> Void)?
    
    
    class func loadFromNib() -> ARChatNavigationView {
        let instance = UINib.init(nibName: "ARChatNavigationView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ARChatNavigationView
        instance.frame.size.width = UIScreen.main.bounds.size.width
        instance.frame.size.height += 10
        return instance
    }
    
    @IBAction func didClickNik(_ sender: UIButton) {
        let nv = ((UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarVC)?.selectedViewController as? UINavigationController)
        let a = nv?.viewControllers.first?.presentedViewController as? OneToOneVC
        
        let vc = ProfileVC.instantiate(from: .Profile)
        vc.isFromChat = true
        vc.viewModel = OtherProfileViewModel.init(with: a!.viewModel.recever!)
        a?.present(vc, animated: true, completion: nil)
        //            nv?.pushViewController(vc, animated: true)
    }
    
    @IBAction func videoCallButton(_ sender: UIButton) {
        didClickVideo?(sender)
    }
    
    @IBAction func audioCallButton(_ sender: UIButton) {
        didClickAudio?(sender)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        didClickBack?(sender)
    }
    
}
