//
//  ARClusteredUsersCell.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/26/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
import Firebase
import UIKit

class ARClusteredUsersCell: UITableViewCell {
    
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderIcon: UIImageView!
    @IBOutlet weak var ageColledLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likiImage: UIImageView!
    @IBOutlet weak var avatar: ARRoundedImageView!
    
    var user: ARUser? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI() {
        if let user = user {
            self.likiImage.tintColor = UIColor.withHex("6A6A77" )
            userFullNameLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")"

            avatar.image = user.getImage()
            if avatar.image == nil {
                avatar.image = UIImage.init(named: user.gender == .male ? "maleAvatar" : "femaleAvatar")
            }
            var age = 0
            let calendar = NSCalendar.current
            if let birtDay = user.birtDay {
                let date1 = calendar.startOfDay(for: birtDay)
                let date2 = calendar.startOfDay(for: Date())
                
                let components = calendar.dateComponents([.year], from: date1, to: date2)
                age = components.year ?? 0
            }
            ageLabel.text = "\(age)"
            ageColledLabel.text = Algorithms.calling(by: age)
            genderIcon.isHighlighted = user.gender == .male
            genderLabel.text = genderIcon.isHighlighted ? "парень" : "девушка"
            
            Database.Likes.likes(userID: user.id ?? "") {[weak self] (likes) in
                let iLike = likes.keys.contains(ARUser.currentUser?.id ?? "")
                self?.likiImage.tintColor = UIColor.withHex(iLike ? "F94865" : "6A6A77" )
                self?.likeCountLabel.text = "\(likes.keys.count)"
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
