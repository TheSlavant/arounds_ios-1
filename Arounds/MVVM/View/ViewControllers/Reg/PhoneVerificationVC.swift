//
//  PhoneVerificationVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import GCCountryPicker
//import InputMask
import UIKit

class PhoneVerificationVC: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var countyCodeLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    //    @IBOutlet weak var listener: PolyMaskTextFieldDelegate!
    
    fileprivate var country: GCCountry!
    var viewModel: PhoneVerificationViewVodel?
    var countyManager = CountyPhoneManager(with: "CountyPhones")
    var countryPickerViewController: GCCountryPickerViewController?
    var countryPickerNavigationController: UINavigationController?
    var countyInfo:CountyInfo? {
        didSet{
            update(with: countyInfo)
        }
    }
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.delegate = self
        //TODO: get current country
        countyInfo = countyManager.info(with: "Russia")
        viewModel?.code = countyCodeLabel.text ?? ""

        // Do any additional setup after loading the view.
    }
    
        override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            self?.phoneTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func countryCodes(_ sender: Any) {
        openCountyPicker()
    }
    
    func openCountyPicker() {
        countryPickerViewController = GCCountryPickerViewController(displayMode: .withCallingCodes)
        guard let countryPickerViewController = countryPickerViewController  else {
            return
        }
//        countryPickerViewController.
        countryPickerViewController.delegate = self
        countryPickerViewController.navigationItem.title = "Страны"
        countryPickerNavigationController = UINavigationController(rootViewController: countryPickerViewController)
        self.present(countryPickerNavigationController!, animated: true, completion: nil)
    }
    
    func update(with county: CountyInfo?) {
        if let countyInfo = countyInfo {
            //            listener.affineFormats = [countyInfo.affineFormat]
//            phoneTextField.placeholder = "countyInfo.pasholder"
            countyCodeLabel.text = countyInfo.callingCode
            //            listener.listener = self
            //            phoneTextField.delegate = listener
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            viewModel?.code = textField.text?.appending(string) ?? ""
            if string == "" {
                return true
            }
            return textField.text?.count ?? 0 < 6
        } else {
            viewModel?.phoneNumber = phoneTextField.text?.appending(string) ?? ""
        }
        return true
    }
    
}


// MARK: - GCCountryPickerDelegate

extension PhoneVerificationVC: GCCountryPickerDelegate {
    
    func countryPickerDidCancel(_ countryPicker: GCCountryPickerViewController) {
        countryPickerViewController?.dismiss(animated: true, completion: nil)
    }
    
    func countryPicker(_ countryPicker: GCCountryPickerViewController, didSelectCountry country: GCCountry) {
        if let callingCode = country.callingCode {
            countyCodeLabel.text = callingCode
            viewModel?.code = callingCode
            countyInfo = countyManager.info(with: country.localizedDisplayName)
        }
        countryPickerNavigationController?.dismiss(animated: true, completion: nil)
    }
    
}

//extension PhoneVerificationVC: MaskedTextFieldDelegateListener {
//
//    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
//        viewModel?.phoneNumber = countyCodeLabel.text?.appending(value)  ?? ""
//        viewModel?.didFillMandatoryCharacters?(complete, textField.text ?? "")
//
//    }
//}

