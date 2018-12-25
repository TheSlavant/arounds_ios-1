//
//  EditVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import MessageUI
//import ALCameraViewController
import Firebase
//import DatePickerDialog
import SVProgressHUD
import UIKit
import CropViewController
import UserNotifications
import Kingfisher


class EditVC: UIViewController {
    
    @IBOutlet var stars: [UILabel]!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var avatarButton: ARBorderedButton!
    @IBOutlet weak var instaButton: ARUITextField!
    @IBOutlet weak var abouteMeTextView: ARTextView!
    @IBOutlet weak var dateButton: ARButton!
    @IBOutlet weak var genderControll: ARSegmentedControl!
    @IBOutlet weak var nicNameTextField: ARBorderedTExtFiled!
    @IBOutlet weak var lastNameTextField: ARBorderedTExtFiled!
    @IBOutlet weak var firstNameTextField: ARBorderedTExtFiled!
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: false  , allowResizing: false, allowMoving: false, minimumSize: CGSize.zero)
    }
    
    //    lazy var photo = MBPhotoPicker()
    lazy var pickerDialog = DatePickerDialog()
    var selectedAvatar: UIImage?
    var viewModel: EditProfileViewModeling? = EditProfileViewModel.init(with: ARUser.currentUser!)
    
    var selectedDate:Date? {
        didSet{
            if let dt = selectedDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.dateButton.titleName = formatter.string(from: dt)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDate = pickerDialog.datePicker.minimumDate
        updateFields()
        listen()
        lastNameTextField.autocapitalizationType = .words
        firstNameTextField.autocapitalizationType = .sentences
        instaButton.buttonTitleLabel.delegate = self
        nicNameTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    func listen() {
        dateButton.didClick = {[weak self] button in
            self?.datePicker()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stars.forEach({$0.sizeToFit()})
        
    }
    
    func updateFields() {
        
        firstNameTextField.text = viewModel?.user?.firstName
        lastNameTextField.text = viewModel?.user?.lastName
        nicNameTextField.text = viewModel?.user?.nickName
        genderControll.setSelected(segment: viewModel?.user?.gender == .male ? .secound : .first)
        abouteMeTextView.text = viewModel?.user?.aboute ?? ""
        selectedDate = viewModel?.user?.birtDay
        backImage.isHidden = viewModel?.isHiddendBackButton ?? false
        backButton.isHidden =  viewModel?.isHiddendBackButton ?? false

        if let resource = viewModel?.user?.getImageURL() {
            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: {[weak self] image, error, cacheType, imageURL in
                self?.selectedAvatar = image
                self?.avatarButton.setImage(image, for: .normal)
            })
        }
        avatarButton.imageView?.contentMode = .scaleAspectFill
        //
        //   self.vkButton.buttonTitleLabel.text = viewModel?.social?.vk ?? ""
        //  self.fbButton.buttonTitleLabel.text = viewModel?.social?.fb ?? ""
        self.instaButton.buttonTitleLabel.text = viewModel?.social?.insta ?? ""
        //  self.twiterButton.buttonTitleLabel.text = viewModel?.social?.twiter ?? ""
    }
    
    func dateTitle(with date: Date) {
        
    }
    
    func datePicker() {
        
        pickerDialog.show("Дата рождения",
                          doneButtonTitle: "Готово",
                          cancelButtonTitle: "Отмена",
                          defaultDate: viewModel?.user?.birtDay ?? Date(), datePickerMode: .date) {[weak self] (date) in
                            if let dt = date {
                                self?.selectedDate = dt
                            }
        }
        
    }
    
    //MARK: Actions
    
    @IBAction func support(_ sender: UIButton) {
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
    
    @IBAction func clickDoneButton(_ sender: UIButton) {
        
        
        if let image = selectedAvatar {
            SVProgressHUD.show()
            let oldImage = ARUser.currentUser?.getImageURL()
            Storage.putImage(image, resize: 320, url: oldImage?.pathComponents.last) { [weak self] (url, error) in
                Database.Inbox.updateMyAvatarFromInboxes(url: url?.absoluteString ?? "", callback: {
                    self?.save(avatarURL: url?.absoluteString)
                    if let error = error {
                        showAlert(error)
                        SVProgressHUD.dismiss()
                    }
                })
            }
        }  else {
            showAlert("Пожалуйста, загрузи фотографию.")
            return
        }
    }
    
    func save(avatarURL: String?) {
        //
        let text = abouteMeTextView.textView.text ?? ""
        
        let trimmedAbouteMe = text.replacingOccurrences(of: "\n", with: " ") //String(text.filter { !" \n".contains($0) })
        let nick = (nicNameTextField.text ?? "").lowercased()
        viewModel?.validate(fields: viewModel?.user?.id ?? "",
                            firstName: firstNameTextField.text ?? "",
                            lastName: lastNameTextField.text ?? "",
                            nicName: nick,
                            gender: genderControll.selected == 1 ? .male : .female,
                            date: selectedDate,
                            aboute: trimmedAbouteMe,
                            avatar: avatarURL ?? "",
                            phone:viewModel?.user?.phone ?? "",
                            insta: instaButton.buttonTitleLabel.text ?? "",
                            completion: {[weak self] (error, userBuilder, errorArray) in
                                
                                self?.errorFields(array: errorArray)
                                
                                if error != nil {
                                    SVProgressHUD.dismiss()

                                } else if let userBuilder = userBuilder {
                                    SVProgressHUD.show()
                                    //
                                    self?.viewModel?.social?.insta = self?.instaButton.buttonTitleLabel.text ?? ""
                                    self?.viewModel?.updateSocial()
                                    //
                                    Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let doct = snapshot.value as? [String: [String: Any]], let _ = doct.filter({($0.value["nickname"] as? String) == nick && ($0.value["nickname"] as? String) != (ARUser.currentUser?.nickName ?? "")}).first {
                                            showAlert("Этот ник уже используется")
                                            SVProgressHUD.dismiss()
                                            return
                                        } else {
                                            self?.updateWith(userBuilder: userBuilder)
                                        }
                                    })
                                }
        })

    }
    
    
    func errorFields(array :[Int]) {
        let gray = UIColor.withHex("EDECEE")
        let red = UIColor.withHex("F94865")
        if array.contains(1) {
            firstNameTextField.borderColor = red
        } else {
            firstNameTextField.borderColor = gray
        }
        
        if array.contains(2) {
            lastNameTextField.borderColor = red
        } else {
            lastNameTextField.borderColor = gray
        }
        
        if array.contains(3) {
            nicNameTextField.borderColor = red
        } else {
            nicNameTextField.borderColor = gray
        }
        
        if array.contains(4) {
            abouteMeTextView.borderColor = red
        } else {
            abouteMeTextView.borderColor = gray
        }
        
        if array.contains(5) {
            instaButton.borderColor = red
        } else {
            instaButton.borderColor = gray
        }
        
        if array.contains(7) {
            dateButton.borderColor = red
        } else {
            dateButton.borderColor = gray
        }
        
    }
    
    func updateWith(userBuilder: ARUpdateUserBuilder) {
        SVProgressHUD.show()
        let nick = (self.nicNameTextField.text ?? "").lowercased()
        let ref =  Database.database().reference().child("users").child(userBuilder.fireID)
        ref.keepSynced(true)
        ref.updateChildValues(userBuilder.makeDict())
        SVProgressHUD.dismiss {
            ARUser.currentUser?.avatarBase64 = userBuilder.avatarBase64
            ARUser.currentUser?.isUpdated = true
            ARUser.currentUser?.nickName = nick
            ARUser.currentUser?.firstName = self.firstNameTextField.text
            ARUser.currentUser?.lastName = self.lastNameTextField.text
            ARUser.currentUser?.birtDay = self.selectedDate
            ARUser.currentUser?.gender =  UserGender.init(rawValue: self.genderControll.selected) ?? .male
            ARUser.currentUser?.aboute = userBuilder.aboute
//            if let selectedAvatar = self.selectedAvatar {
//                ARUser.currentUser?.setImage(image: selectedAvatar)
//            }
            ARUser.currentUser?.save()
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            //
            if LocationStatusTracker.shared.isNotDetermined() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    LocationRequired.shared.show()
                }
            } else {
                let center = UNUserNotificationCenter.current()
                center.getNotificationSettings { (settings) in
                    NotificationRequired.shared.show(hide: (settings.authorizationStatus != .notDetermined))
                }
                
            }
            
        }
        
        //        self.viewModel?.update(user: userBuilder, completion: { (error, success) in
        //            SVProgressHUD.dismiss(completion: {
        //                if success == true {
        //                    ARUser.currentUser?.isUpdated = true
        //                    ARUser.currentUser?.nickName = nick
        //                    ARUser.currentUser?.firstName = self.firstNameTextField.text
        //                    ARUser.currentUser?.lastName = self.lastNameTextField.text
        //                    ARUser.currentUser?.birtDay = self.selectedDate
        //                    ARUser.currentUser?.gender =  UserGender.init(rawValue: self.genderControll.selected) ?? .male
        //                    ARUser.currentUser?.aboute = self.abouteMeTextView.textView.text ?? ""
        //                    if let selectedAvatar = self.selectedAvatar {
        //                        ARUser.currentUser?.setImage(image: selectedAvatar)
        //                    }
        //                    ARUser.currentUser?.save()
        //                    if let nav = self.navigationController {
        //                        nav.popViewController(animated: true)
        //                    } else {
        //                        self.dismiss(animated: true, completion: nil)
        //                    }
        //                } else {
        //                    showAlert(error?.localizedDescription ?? "")
        //                }
        //            })
        //        })
        //
    }
    
    
    @IBAction func clickaAvatarButton(_ sender: UIButton) {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let uploadPhoto = UIAlertAction.init(title: "Выбрать фото", style: .default, handler: { [weak self] (action) in
            
            guard let weakSelf = self else {return}
            
            let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: weakSelf.croppingParameters) { [weak self] image, asset in
                guard let image = image else {
                    self?.dismiss(animated: true, completion: nil)
                    return}
                self?.cropImage(image: image)
            }
            
            self?.present(libraryViewController, animated: true, completion: nil)
            
        })
        
        let takePhoto = UIAlertAction.init(title: "Снять фото", style: .default, handler: {[weak self] (action) in
            
            guard let weakSelf = self else {return}
            
            let cameraViewController = CameraViewController(croppingParameters: weakSelf.croppingParameters, allowsLibraryAccess: false) { [weak self] image, asset in
                
                guard let image = image else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                    
                }
                self?.cropImage(image: image)
            }
            
            self?.present(cameraViewController, animated: true, completion: nil)
            
        })
        
        let cancel = UIAlertAction.init(title: NSLocalizedString("Отмена", comment: ""), style: .cancel, handler: { (action) in
            
        })
        
        actionSheet.addAction(uploadPhoto)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(cancel)
        actionSheet.show()
        //        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func cropImage(image: UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.delegate = self
        self.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.present(cropViewController, animated: true)
            }
        })
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swipeLeftGesture(_ sender: UIPanGestureRecognizer) {
        //        self.navigationController?.popViewController(animated: true)
    }
    
    //    deinit {
    //        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert] , completionHandler: { (granted, error) in
    //            UserDefaults.standard.set(true, forKey: "askingAccess")
    //            UserDefaults.standard.synchronize()
    //            UserDefaults.standard.set(granted, forKey: "notificationGranted")
    //            UserDefaults.standard.synchronize()
    //
    //            //            DispatchQueue.main.async {
    //            //                NotificationRequired.shared.show(hide: granted)
    //            //            }
    //
    //            if error != nil {
    //
    //            } else {
    //
    //                DispatchQueue.main.async {
    //                    UIApplication.shared.registerForRemoteNotifications()
    //                }
    //            }
    //        })
    //
    //
    //    }
}

extension EditVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {return true}
        if textField == nicNameTextField && textField.text?.count ?? 0 + 2 >= 20 {
            return false
        }
        
        return true
    }
}


extension EditVC: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        if let image = image.resize(toWidth: 1540) {
            avatarButton.setImage(image, for: .normal)
            self.selectedAvatar = image
            avatarButton.contentMode = .scaleAspectFill
            avatarButton.imageView?.contentMode = .scaleAspectFill
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension EditVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}



