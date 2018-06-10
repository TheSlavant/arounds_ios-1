//
//  EditVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/2/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import DatePickerDialog
import MBPhotoPicker
import SVProgressHUD
import UIKit

class EditVC: UIViewController {
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var avatarButton: ARBorderedButton!
    @IBOutlet weak var twiterButton: ARUITextField!
    @IBOutlet weak var vkButton: ARUITextField!
    @IBOutlet weak var instaButton: ARUITextField!
    @IBOutlet weak var fbButton: ARUITextField!
    @IBOutlet weak var abouteMeTextView: ARTextView!
    @IBOutlet weak var dateButton: ARButton!
    @IBOutlet weak var genderControll: ARSegmentedControl!
    @IBOutlet weak var nicNameTextField: ARBorderedTExtFiled!
    @IBOutlet weak var fullNameTextField: ARBorderedTExtFiled!
    
    lazy var photo = MBPhotoPicker()
    lazy var pickerDialog = DatePickerDialog()
    var selectedAvatar: UIImage?
    var viewModel: EditProfileViewModeling? = EditProfileViewModel.init(with: ARUser.currentUser!)
    
    var selectedDate:Date? {
        didSet{
            if let dt = selectedDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.dateButton.titleName = formatter.string(from: dt)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDate = pickerDialog.datePicker.minimumDate
        updateFields()
        listen()
        // Do any additional setup after loading the view.
    }
    
    
    func listen() {
        dateButton.didClick = {[weak self] button in
            self?.datePicker()
        }
    }
    
    func updateFields() {
        
        fullNameTextField.text = viewModel?.user?.fullName
        nicNameTextField.text = viewModel?.user?.nickName
        genderControll.setSelected(segment: viewModel?.user?.gender == .male ? .secound : .first)
        abouteMeTextView.text = viewModel?.user?.aboute ?? ""
        selectedDate = viewModel?.user?.birtDay
        backImage.isHidden = viewModel?.isHiddendBackButton ?? false
        backButton.isHidden =  viewModel?.isHiddendBackButton ?? false
        if let image = viewModel?.user?.getImage() {
            selectedAvatar = image
            avatarButton.setImage(image, for: .normal)
        }
        avatarButton.imageView?.contentMode = .scaleAspectFill
        //

        
        viewModel?.didFetchedSocial = { [weak self] (social) in
            self?.vkButton.buttonTitleLabel.text = social?.vk ?? ""
            self?.fbButton.buttonTitleLabel.text = social?.fb ?? ""
            self?.instaButton.buttonTitleLabel.text = social?.insta ?? ""
            self?.twiterButton.buttonTitleLabel.text = social?.twiter ?? ""
        }
    }
    
    func dateTitle(with date: Date) {
        
    }
    
    func datePicker() {
        
        pickerDialog.show("Выберите дата рождения",
                                doneButtonTitle: "Готово",
                                cancelButtonTitle: "Отмена",
                                defaultDate: viewModel?.user?.birtDay ?? Date(), datePickerMode: .date) {[weak self] (date) in
                                    if let dt = date {
                                        self?.selectedDate = dt
                                    }
        }
        
    }
    
    //MARK: Actions
    
    @IBAction func clickDoneButton(_ sender: UIButton) {
        var avatarBase64 = ""
        if let image = selectedAvatar, let imageData = UIImageJPEGRepresentation(image, 0.4) {
            avatarBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        }
        //
        viewModel?.social?.vk = vkButton.buttonTitleLabel.text ?? ""
        viewModel?.social?.fb = fbButton.buttonTitleLabel.text ?? ""
        viewModel?.social?.insta = instaButton.buttonTitleLabel.text ?? ""
        viewModel?.social?.twiter = twiterButton.buttonTitleLabel.text ?? ""
        viewModel?.updateSocial()
        //
        viewModel?.validate(fields: viewModel?.user?.id ?? "",
                            fullName: fullNameTextField.text ?? "",
                            nicName: nicNameTextField.text ?? "",
                            gender: genderControll.selected == 1 ? .male : .female,
                            date: selectedDate,
                            aboute: abouteMeTextView.textView.text,
                            avatar: avatarBase64,
                            phone:viewModel?.user?.phone ?? "",
                            completion: {[weak self] (error, userBuilder) in
                                
                                if error != nil {
                                    showAlert(error!)
                                } else if let userBuilder = userBuilder {
                                    SVProgressHUD.show()
                                    
                                    self?.viewModel?.update(user: userBuilder, completion: { (error, success) in
                                        SVProgressHUD.dismiss(completion: {
                                            if success == true {
                                                ARUser.currentUser?.isUpdated = true
                                                ARUser.currentUser?.nickName = self?.nicNameTextField.text ?? ""
                                                ARUser.currentUser?.fullName = self?.fullNameTextField.text ?? ""
                                                ARUser.currentUser?.birtDay = self?.selectedDate
                                                ARUser.currentUser?.gender =  (self?.genderControll.selected).map { UserGender(rawValue: $0) } ?? .male
                                                if let selectedAvatar = self?.selectedAvatar {
                                                    ARUser.currentUser?.setImage(image: selectedAvatar)
                                                }
                                                ARUser.currentUser?.save()
                                                if let nav = self?.navigationController {
                                                    nav.popViewController(animated: true)
                                                } else {
                                                    self?.dismiss(animated: true, completion: nil)
                                                }
                                            } else {
                                                showAlert(error?.localizedDescription ?? "")
                                            }
                                        })
                                    })
                                }
        })
    }
    
    @IBAction func clickaAvatarButton(_ sender: UIButton) {
        //        photo.allowEditing =  true
        photo.allowDestructive = true
        photo.disableEntitlements = true
        
        photo.onPhoto = {[weak self] (image: UIImage!) -> Void in
            sender.setImage(image, for: .normal)
            self?.selectedAvatar = image
            sender.contentMode = .scaleAspectFill
            sender.imageView?.contentMode = .scaleAspectFill
        }
        photo.onCancel = {
            print("Cancel Pressed")
        }
        photo.onError = { (error) -> Void in
            print("Error: \(error.rawValue)")
        }
        photo.present(self)
        
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
