//
//  RadarMessageCell.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import Firebase
import UIKit
import JSQMessagesViewController.JSQMessage
import Kingfisher

class RadarMessageCell: UITableViewCell {
    
    var didBlockMessage: ((String, String, [String]) -> Void)?
    
    @IBOutlet weak var lableRigheConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContentView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nicNameLabel: UILabel!
    @IBOutlet weak var messageParentView: UIView!
    @IBOutlet weak var textLable: UILabel!
    @IBOutlet weak var blockButon: UIButton!
    
    var user: ARUser? {
        didSet{
            guard let user = user else { return }
            avatarImageView.kf.setImage(with: user.getImageURL())
            nicNameLabel.text = "@" + (user.nickName ?? "")
        }
    }
    
    var message: RadarMessage! {
        didSet{
            textLable.text = message.text
            
            dateLabel.text = getFormattedDate(for: message.date) ?? ""
            
            Database.Users.user(userID: message.senderID) { (newUser) in
                self.user = newUser
            }
            messageParentView.layer.cornerRadius = 10
            avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
            
            blockButon.isHidden = (message.senderID == ARUser.currentUser?.id)
            blockButon.isEnabled = message.blockers.contains(ARUser.currentUser?.id ?? "") == false
            lableRigheConstraint.constant = blockButon.isHidden ? 0-5 : 20
            DispatchQueue.main.async {
                self.dropShadow(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3), opacity: 0.3, offSet: CGSize(width: -2.0, height: 2.0), radius: 5, scale: true, view: self.textContentView)
            }
            
        }
        
    }
    
    func getFormattedDate(for date: Date) -> String? {
        let formatter = DateFormatter()
        if NSCalendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return "Сегодня, \(formatter.string(from: date))"
        } else if NSCalendar.current.isDateInYesterday(date) {
            formatter.dateFormat = "HH:mm"
            return "Вчера, \(formatter.string(from: date))"
        }
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true, view: UIView) {
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
        
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    @IBAction func blockButton(_ sender: UIButton) {
        
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let blockAction = UIAlertAction.init(title: "Пожаловаться", style: .default, handler: { [unowned self] (action) in
            
            Database.RadarMessage.block(messageID: self.message.id, senderID: self.message.senderID, blockers: self.message.blockers)
            
            self.blockButon.isHidden = true
            
        })
        
        let cancel = UIAlertAction.init(title: NSLocalizedString("Отмена", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancel)
        actionSheet.show()
//        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func avatarTapped(_ sender: UIButton) {
        if user?.id == ARUser.currentUser?.id {return}
        let nv = ((UIApplication.shared.keyWindow?.rootViewController as? HomeTabBarVC)?.selectedViewController as? UINavigationController)
        let a = nv?.viewControllers.first as? ChatListVC
        
        let vc = ProfileVC.instantiate(from: .Profile)
        vc.isFromChat = true
        vc.viewModel = OtherProfileViewModel.init(with: user!)
        a?.present(vc, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
