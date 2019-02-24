//
//  ARMarker.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/20/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import Kingfisher

class ARMarker: UIView {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var borderImageView: UIImageView!
    var user:ARUser!
    
    class func loadFromNib(with user: ARUser, complition: @escaping (()->Void)) -> ARMarker {
        let instance = UINib(nibName: "ARMarker", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ARMarker
        instance.user = user
        instance.frame.size = user.id == ARUser.currentUser?.id ?? "" ?  CGSize(width: 130, height: 130) : CGSize(width: 100, height: 100)
        
        DispatchQueue.global().async {
            if let url = user.getImageURL(), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    instance.imageView.image = UIImage(data: data)
                    complition()
                }
            } else {
                DispatchQueue.main.async {
                    complition()
                }
            }
        }
        //        instance.imageView.kf.setImage(with: user.getImageURL()) { (image, error, cacheType, url) in
        //
        //        }
        
        return instance
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = color.cgColor
        shadowView.layer.shadowOpacity = opacity
        shadowView.layer.shadowOffset = offSet
        shadowView.layer.shadowRadius = radius
        
        shadowView.layer.shadowPath = UIBezierPath(rect: CGRect.init(x: 0, y: 0, width: 30, height: 30)).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
}
