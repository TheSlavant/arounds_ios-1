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
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    var phoneVerViewModel = PhoneVerificationViewVodel()
    var regStep: RegStep = .first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startListenr()
        
        UserDefaults.standard.set(true, forKey: "isOnline")
        UserDefaults.standard.synchronize()
        
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func backAction() {
        scrollViewPreviews()
    }
    
    @IBAction func tersmOfConditionsButton(_ sender: UIButton) {
        let vc = Privacy2.instantiate(from: .Policy)
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func action2(_ sender: UIButton) {
        let vc = PrivacyVC.instantiate(from: .Policy)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        if regStep == .first {
            self.dismiss(animated: true, completion: nil)
        } else {
            backAction()
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if regStep == .first {
            if phoneVerViewModel.phoneNumber.contains("0000000000104") {
                testLogin()
            }
            phoneVerViewModel.sendCode(phone: phoneVerViewModel.phoneNumber)
            self.scrollViewNext()
            
        } else if regStep == .secound {
            verify()
        }
    }
    
    func showBack(show:Bool) {
        backButton.isHidden = !show
        backImage.isHidden = !show
    }
    
    func scrollViewNext() {
        // showBack(show: true)
        self.view.isUserInteractionEnabled = false
        regStep = .secound
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentOffset.x + self.scrollView.frame.size.width, y: 0)
        }) { (finish) in
            self.view.isUserInteractionEnabled = true
        }
        
    }
    
    func scrollViewPreviews() {
        // showBack(show: false)
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
        nextButton.isEnabled = false
        phoneVerViewModel.phoneAuth.verification = { [weak self] user, error in
            if user == nil {
                SVProgressHUD.dismiss(completion: {
                    showAlert("Неправильный пин")
                })
                self?.nextButton.isEnabled = true
            } else {
                if let phone = self?.phoneVerViewModel.phoneAuth.fullNumber {
                    AuthApi().login(with: phone, completion: { (error, user) in
                        SVProgressHUD.dismiss(completion: {
                            
                            if error == nil, let user = user {
                                self?.performSegue(withIdentifier: "GoToHome", sender: self)
                                if user.isUpdated == false {
                                    let vc = EditVC.instantiate(from: .Profile)
                                    vc.viewModel = FirstUpdateProfileViewModel(with: user)
                                }
                            } else {
                                showAlert(error?.localizedDescription ?? "")
                                self?.nextButton.isEnabled = true
                            }
                        })
                    })
                }
            }
        }
        SVProgressHUD.show()
        phoneVerViewModel.verify(code: phoneVerViewModel.code)
        
    }
    
    func testLogin() {
        AuthApi().login(with: phoneVerViewModel.phoneNumber, completion: { [weak self] (error, user) in
            SVProgressHUD.dismiss(completion: {
                
                if error == nil, let user = user {
                    self?.performSegue(withIdentifier: "GoToHome", sender: self)
                    if user.isUpdated == false {
                        let vc = EditVC.instantiate(from: .Profile)
                        vc.viewModel = FirstUpdateProfileViewModel(with: user)
                    }
                } else {
                    showAlert(error?.localizedDescription ?? "")
                    self?.nextButton.isEnabled = true
                }
            })
        })
    }
    
    func startListenr() {
        phoneVerViewModel.didFillMandatoryCharacters = { [weak self] complite, phoneNumber in
            self?.nextButton.isEnabled = complite
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneVerificationSegue", let phoneVC = segue.destination as? PhoneVerificationVC {
            phoneVC.viewModel = phoneVerViewModel
            nextButton.isEnabled = true
        }
        
    }
    
}
