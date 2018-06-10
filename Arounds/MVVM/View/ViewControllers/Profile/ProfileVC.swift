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
    
    @IBOutlet weak var vkImage: UIImageView!
    @IBOutlet weak var twiterImage: UIImageView!
    @IBOutlet weak var instaImage: UIImageView!
    @IBOutlet weak var fbImage: UIImageView!
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
    
    var viewModel: ProfileViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SetupUI()
        listeners()
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
        messageButtonParentBottomConstraint.constant = me ? (0-40) : 0
        view.layoutIfNeeded()
        let iLiked = user.profileLike?.likedUserIds.contains(ARUser.currentUser?.id ?? "") ?? false
        isLikedLabel.tintColor = UIColor.withHex(iLiked == false ? "6A6A77" : "F94865")
        aboutLabel.text = user.aboute
        userName.text = user.fullName
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
        
        viewModel?.didFetchedSocial = { [weak self] (social) in
            let selected = UIColor.withHex("F94865")
            let deSelected = UIColor.withHex("6A6A77")
            self?.vkImage.tintColor = social?.vk.count ?? 0 > 0 ? selected : deSelected
            self?.fbImage.tintColor = social?.fb.count ?? 0 > 0 ? selected : deSelected
            self?.instaImage.tintColor = social?.insta.count ?? 0 > 0 ? selected : deSelected
            self?.twiterImage.tintColor = social?.twiter.count ?? 0 > 0 ? selected : deSelected
        }
    }
    
    @IBAction func clickSocial(_ sender: UIButton) {
        
        switch Social.init(rawValue: sender.tag)! {
        case .fb:
            if let url = URL.init(string: viewModel?.social?.fb ?? "") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            break
        case .insta:
            if let url = URL.init(string: viewModel?.social?.insta ?? "") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            break
        case .vk:
            if let url = URL.init(string: viewModel?.social?.vk ?? "") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            break
        case .wtiter:
            if let url = URL.init(string: viewModel?.social?.twiter ?? "") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            break
            
        }
    }
    
    @IBAction func likeButton(_ sender: ARGradientedButton) {
        if let fromID = ARUser.currentUser?.id,let toID = viewModel?.user?.id {
            if viewModel?.isILike ?? false {
                Database.Likes.dislike(fromID: fromID, toID: toID)
            } else {
                Database.Likes.like(fromID: fromID, toID: toID)
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
            
            break
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
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
        likeButton.startColor = startColor
        likeButton.endColor = endColor
        
    }
    
}
