//
//  MessageImageView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 4/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

final class MessageImageView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var outgoingMessageStatusStackView: UIStackView!
    @IBOutlet weak var outgoingMessageTimeLabel: UILabel!
    @IBOutlet weak var outgoingMessageStatusImageView: UIImageView!

    @IBOutlet weak var incommingMessageTimeLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
}
