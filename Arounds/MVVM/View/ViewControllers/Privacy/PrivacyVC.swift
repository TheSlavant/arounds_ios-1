//
//  PrivacyVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import StoreKit
import UIKit
import SVProgressHUD

class PrivacyVC: UIViewController, UITextViewDelegate, SKStoreProductViewControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @IBAction func clickButtonBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let storeViewController = SKStoreProductViewController.init()
        storeViewController.delegate = self
        SVProgressHUD.show()
        storeViewController.loadProduct(withParameters: [ SKStoreProductParameterITunesItemIdentifier : "1419753904"]) { [weak self] (loaded, error) in
            SVProgressHUD.dismiss()
            if loaded {
                DispatchQueue.main.async {
                    self?.present(storeViewController, animated: true, completion: nil)
                }
            }
            
        }
        //        UIApplication.shared.open(URL, options: [:])
        return false
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

    
    
}
