//
//  UIImageView+ImageLoading.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/12/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit
import Kingfisher

extension Notification.Name {
    public static var KingfisherDidDownloadImage = Notification.Name("KingfisherDidDownloadImage")
}

extension UIImageView {
    
    @discardableResult
    public func setImage(with resource: Resource?,
                         placeholder: Placeholder? = nil,
                         options: KingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler? = nil) -> RetrieveImageTask {
        
        return self.kf.setImage(with:resource,
                                placeholder:placeholder,
                                options:options,
                                progressBlock:progressBlock) { (image, error, cacheType, url) in
                                    completionHandler?(image, error, cacheType, url)
                                    NotificationCenter.default.post(name: Notification.Name.KingfisherDidDownloadImage, object: nil)
        }
    }
    
}
