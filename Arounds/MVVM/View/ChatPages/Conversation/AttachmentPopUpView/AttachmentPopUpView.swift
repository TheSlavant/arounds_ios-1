//
//  AttachmentPopUpView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/11/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import Presentr

enum AttachmentPopUpItem {
    case gallery
    case camera
    case audio
}

class AttachmentPopUpView: UIViewController {
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var voiceButton: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: AttachmentPopUpViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.updateTheme()
        self.bgView.layer.cornerRadius = 15
        self.cancelButton.layer.cornerRadius = 10
    }
    
    func updateTheme() {
        let isDarkTheme = UserDefaults.standard.bool(forKey: "darkTheme")
        if !isDarkTheme {
            self.setLightTheme()
        } else {
            self.setDarkTheme()
        }
    }
    
    func setLightTheme() {
        bgView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.9)
        
        self.photoButton.setTitleColor(UIColor.black, for: .normal)
        self.cameraButton.setTitleColor(UIColor.black, for: .normal)
        self.voiceButton.setTitleColor(UIColor.black, for: .normal)
        self.cancelButton.backgroundColor = .white
    }
    
    func setDarkTheme() {
        self.bgView.backgroundColor = .black
        self.bgView.layer.borderColor = UIColor.white.cgColor
        self.bgView.layer.borderWidth = 0.5
        
        self.cancelButton.backgroundColor = .black
        self.cancelButton.layer.borderColor = UIColor.white.cgColor
        self.cancelButton.layer.borderWidth = 0.5
        self.photoButton.setTitleColor(UIColor.white, for: .normal)
        self.cameraButton.setTitleColor(UIColor.white, for: .normal)
        self.voiceButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    @IBAction func photoButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.didSelectItem(.gallery, in: self)
        })
    }
    
    @IBAction func cameraButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.didSelectItem(.camera, in: self)
        })
    }
    
    @IBAction func voiceButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.didSelectItem(.audio, in: self)
        })
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    class func show(for viewController: UIViewController, delegate: AttachmentPopUpViewDelegate?) {
        let popUpView: Presentr = {
            let width = ModalSize.custom(size: Float(viewController.view.frame.width - 4))
            let height = ModalSize.custom(size: 257)
            let center = ModalCenterPosition.customOrigin(origin: CGPoint.init(x: 2, y: UIScreen.main.bounds.height - 257 ))
            let customType = PresentationType.custom(width:  width, height: height, center: center)
            
            let customPresenter = Presentr(presentationType: customType)
            return customPresenter
        }()
        
        let selectionView = AttachmentPopUpView()
        selectionView.delegate = delegate
        viewController.customPresentViewController(popUpView, viewController: selectionView, animated: true, completion: nil)
    }
}

protocol AttachmentPopUpViewDelegate: class {
    func didSelectItem(_ item: AttachmentPopUpItem, in attachmentPopUpView: AttachmentPopUpView)
}
