//
//  ProfileVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/1/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import SVProgressHUD
import Firebase
import AlamofireImage
import UIKit

enum RightButtonMode: Int {
    case edit = 0
    case block = 1
}

enum Social: Int {
    case fb = 1
    case insta = 2
    case wtiter = 3
    case vk = 4
}

class ProfileVC: UIViewController {
    
    @IBOutlet weak var likeShadow: UIImageView!
    @IBOutlet weak var myInstaView: UIView!
    @IBOutlet weak var instaLabel: UILabel!
    @IBOutlet weak var instaButton: ARBorderedButton!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var otherInstaImage: UIImageView!
    @IBOutlet weak var instaImage: UIImageView!
    @IBOutlet weak var likeButton: ARGradientedButton!
    @IBOutlet weak var calledAgesLabel: UILabel!
    @IBOutlet weak var messageWhiteVIew: UIView!
    @IBOutlet weak var editButtonImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButtonImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var messageButtonParentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderIamge: UIImageView!
    @IBOutlet weak var isLikedLabel: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nikName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: ARRoundedImageView!
    @IBOutlet weak var likeButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var otherInstaButton: ARBorderedView!
    
    var isFromChat = false
    var viewModel: ProfileViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        instaButton.imageView?.contentMode = .scaleToFill
        instaButton.isHidden = !(viewModel?.user?.isMe)!
        myInstaView.isHidden = instaButton.isHidden
        otherInstaButton.isHidden = (viewModel?.user?.isMe)!
//        myInstaButton.isHidden = !(viewModel?.user?.isMe)!
        likeButtonRightConstraint.constant = (viewModel?.user?.isMe)! ? 12 : 69
        view.layoutIfNeeded()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.aboutLabel.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel?.user?.id ?? "" == ARUser.currentUser?.id {
            viewModel?.user = ARUser.currentUser
        }
        SetupUI()
        listeners()
        let a = ARProfileBlock.rebase().blockListByMe.contains(viewModel?.user?.id ?? "")

        editButton.isHighlighted = a
        editButtonImage.tintColor = (a == true) ? .gray : .red
        
        viewModel?.startFatchingSocial()
        viewModel?.didFetchedSocial = { [weak self] (social) in
            DispatchQueue.main.async {
                let alpha:CGFloat = social?.insta.count ?? 0 > 0 ? 1 : 0.4
                self?.instaImage.alpha = alpha
                self?.instaButton.alpha =  alpha
                self?.instaButton.isEnabled = social?.insta.count ?? 0 > 0
                self?.otherInstaImage.alpha = social?.insta.count ?? 0 > 0 ? 1 : 0.4
                self?.instaLabel.alpha = alpha
            }
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func SetupUI() {
        guard let user = viewModel?.user else {
            return
        }
        let me = user.me
        backButtonImage.isHidden = me
        backButton.isHidden = me
        editButtonImage.isHighlighted = !me
        editButton.tag = me ? 0 : 1
        messageWhiteVIew.isHidden = !me
        messageButtonParentBottomConstraint.constant = me ? (0-67) : 0
        view.layoutIfNeeded()
        let iLiked = user.profileLike?.likedUserIds.contains(ARUser.currentUser?.id ?? "") ?? false
        isLikedLabel.tintColor = UIColor.withHex(iLiked == false ? "6A6A77" : "F94865")
        self.aboutLabel.text = user.aboute
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.aboutLabel.isHidden = false
            self.aboutLabel.sizeToFit()

        }

        userName.text = user.firstName
        lastName.text = user.lastName
        nikName.text = "@".appending(user.nickName ?? "")
        
        var age = 0
        let calendar = NSCalendar.current
        if let birtDay = user.birtDay {
            let date1 = calendar.startOfDay(for: birtDay)
            let date2 = calendar.startOfDay(for: Date())
            
            let components = calendar.dateComponents([.year], from: date1, to: date2)
            age = components.year ?? 0
        }
        ageLabel.text = "\(age)"
        calledAgesLabel.text = Algorithms.calling(by: age)
        likeCount.text = "\(user.profileLike?.likedUserIds.count ?? 0)"
        genderIamge.image = UIImage(named: user.gender == .female ? "female_icon" : "male_icon")
        genderLabel.text = user.gender == .female ? "девушка" : "парень"
        let defoultImage = UIImage(named: user.gender == .female ? "femaleAvatar" : "maleAvatar")
        userImage.image = defoultImage
        
        if let image = user.getImage() {
            userImage.image = image
        } else {
            userImage.image = defoultImage
        }
        
    }
    
    
    @IBAction func chatButton(_ sender: UIButton) {
        if isFromChat == true {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        sender.isEnabled = false
        SVProgressHUD.show()
        Database.Chat.getChat(reciverID: viewModel?.user?.id ?? "") { (chat, error) in
            if let chat = chat {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    let vc = OneToOneVC.create(with: chat)
                    self.present(vc, animated: true, completion: nil)
                    sender.isEnabled = true
                    SVProgressHUD.dismiss()
                })
                
                ////                DispatchQueue.main.async {
                //                    self.present(vc, animated: true, completion: nil)
                //                    sender.isEnabled = true
                //                    SVProgressHUD.dismiss()
                ////                }
            }
        }
    }
    
    @IBAction func clickSocial(_ sender: UIButton) {
        var instaString = ""
        if let insta = viewModel?.social?.insta, insta.count > 0 {
            if insta.contains("www.") && insta.hasPrefix("https://www.instagram.com") == true {
                instaString = insta
            } else {
                if insta.hasPrefix("/") {
                    instaString = "https://www.instagram.com" + insta
                } else {
                    instaString = "https://www.instagram.com/" + insta
                }
            }
        }
        
        if let url = URL.init(string: instaString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func likeButton(_ sender: ARGradientedButton) {
        if let fromID = ARUser.currentUser?.id,let toID = viewModel?.user?.id {
            if viewModel?.isILike ?? false {
                Database.Likes.dislike(fromID: fromID, toID: toID)
            } else {
                Database.Likes.like(fromID: fromID, toID: toID, DCS: viewModel?.user?.DCS)
            }
            listeners()
        }
    }
    
    @IBAction func topRightButton(_ sender: UIButton) {
        
        switch RightButtonMode(rawValue: sender.tag)! {
        case .edit:
            performSegue(withIdentifier: "editProfileSegue", sender: self)
            break
        case .block:
            blockSheet()
            break
        }
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        if isFromChat == true {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func listeners() {
        viewModel?.likes(handler: { [weak self] (likes) in
            self?.likeCount.text = "\(likes.keys.count)"
            self?.updateByLiked(like: self?.viewModel?.isILike ?? false)
        })
    }
    
    func updateByLiked(like: Bool) {
        isLikedLabel.tintColor = UIColor.withHex( like ? "F94865" : "6A6A77")
        
        var startColor = UIColor.withHex("FF3FB4")
        var endColor = UIColor.withHex("F35119")
        
        if like {
            startColor = UIColor.withHex("F1EAEF")
            endColor = UIColor.withHex("F1EAEF")
        }
        
        likeShadow.isHidden = like

        likeButton.startColor = startColor
        likeButton.endColor = endColor
        
    }
    
    func blockSheet() {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let block = ARProfileBlock.rebase().blockListByMe.contains(viewModel?.user?.id ?? "")
        
        let blockAction = UIAlertAction.init(title: block == true ? "Разблокировать" : "Блокировать", style: .default, handler: { [weak self] (action) in
            SVProgressHUD.show()
            if block == true {
                Database.ProfileBlock.unblock(profile: self?.viewModel?.user?.id ?? "", callback: { (finish) in
                    SVProgressHUD.dismiss()
                    if let index = self?.viewModel?.userBlock?.blockList.index(of: ARUser.currentUser?.id ?? "") {
                        self?.viewModel?.userBlock?.blockList.remove(at: index)
                    }
                    
                    //                    self?.editButton.isEnabled = true
                    DispatchQueue.main.async {
                        self?.editButtonImage.tintColor = .red
                    }
                    
                })
            } else {
                Database.ProfileBlock.block(profile: self?.viewModel?.user?.id ?? "", callback: { [weak self] (finish) in
                    SVProgressHUD.dismiss()
                    self?.viewModel?.userBlock?.blockList.append(ARUser.currentUser?.id ?? "")
                    
                    //                    self?.editButton.isEnabled = true
                    DispatchQueue.main.async {
                        self?.editButtonImage.tintColor = .gray
                    }
                    
                })
            }
        })
        
        let cancel = UIAlertAction.init(title: NSLocalizedString("Отмена", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
}


