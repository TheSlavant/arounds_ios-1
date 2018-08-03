//
//  Privacy2.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 7/30/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class Privacy2: UIViewController {
    
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
    
}
