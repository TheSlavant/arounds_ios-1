//
//  RegVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import SVProgressHUD
import UIKit

enum RegStep {
    case first
    case secound
}

class RegVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    var phoneVerViewModel = PhoneVerificationViewVodel()
    var regStep: RegStep = .first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startListenr()
        setupNavBar()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func setupNavBar() {
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(self.backAction))
        //        let yourBackImage = UIImage(named: "arrowBack")?.resizeImage(width: 30)
        let yourBackImage = UIImage(named: "arrowBack")
        
        backButton.image = yourBackImage
        navigationItem.leftBarButtonItem = backButton
        // self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        //self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        UINavigationBar.appearance().tintColor = UIColor.withHex("88889C")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    @objc func backAction() {
        scrollViewPreviews()
    }
    
    @IBAction func tersmOfConditionsButton(_ sender: UIButton) {
        let vc = PrivacyVC.instantiate(from: .Policy)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if regStep == .first {
            phoneVerViewModel.sendCode(phone: phoneVerViewModel.phoneNumber)
            self.scrollViewNext()
            
        } else if regStep == .secound {
            verify()
        }
        
    }
    
    func scrollViewNext() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.isUserInteractionEnabled = false
        regStep = .secound
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentOffset.x + self.scrollView.frame.size.width, y: 0)
        }) { (finish) in
            self.view.isUserInteractionEnabled = true
        }
        
    }
    
    func scrollViewPreviews() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.isUserInteractionEnabled = false
        regStep = .first
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentOffset.x - self.scrollView.frame.size.width, y: 0)
        }) { (finish) in
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func verify() {
        phoneVerViewModel.phoneAuth.verification = { [weak self] user, error in
            if user == nil {
                SVProgressHUD.dismiss(completion: {
                    showAlert("Wrong pin")
                })
            } else {
                SVProgressHUD.dismiss(completion: {
                    if let phone = self?.phoneVerViewModel.phoneAuth.fullNumber {
                        AuthApi().login(with: phone, completion: { (error, user) in
                            if error == nil, let user = user {
                                self?.performSegue(withIdentifier: "GoToHome", sender: self)
                                if user.isUpdated == false {
                                    let vc = EditVC.instantiate(from: .Profile)
                                    vc.viewModel = FirstUpdateProfileViewModel(with: user)
                                }
                            }
                        })
                    }
                })
            }
        }
        SVProgressHUD.show()
        phoneVerViewModel.verify(code: phoneVerViewModel.code)
        
    }
    
    func reg() {
        
    }
    
    func startListenr() {
        phoneVerViewModel.didFillMandatoryCharacters = { [weak self] complite, phoneNumber in
            self?.nextButton.isEnabled = complite
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneVerificationSegue", let phoneVC = segue.destination as? PhoneVerificationVC {
            phoneVC.viewModel = phoneVerViewModel
        }
        
    }
    
}
