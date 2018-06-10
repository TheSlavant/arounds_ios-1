//
//  ARTextView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

@IBDesignable
class ARTextView: ARBorderedView  {
    
    var text = "" {
        didSet{
            mode(isPlaceholder: text.count == 0)
            if  text.count > 0 {
                textView.text = text
            }
            rangeLabel.text = "\(textView.text.count)/\(max)"

//            rangeLabel.text = "\(textView.text.count)/\(max)"
        }
    }
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBInspectable var max: Int = 100
    @IBInspectable var placeholder: String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI(name: self.nameOfClass)
        textView.delegate = self
        mode(isPlaceholder: text.count == 0)
        if  text.count > 0 {
            textView.text = text
        }
        rangeLabel.text = "\(textView.text.count)/\(max)"

    }
}

extension ARTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = textView.text.count
        //
        if text != "" && count == max {
            return false
        }
        //
        let characterCount = text == "" ? count - 1 : count + text.count
        rangeLabel.text = "\(characterCount < 0 ? 0 : characterCount)/\(max)"
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            mode(isPlaceholder: false)
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            mode(isPlaceholder: true)
        }
    }
    
    func mode(isPlaceholder: Bool) {
        if isPlaceholder {
            textView.text = placeholder
            textView.textColor = .lightGray
        } else {
            textView.text = text
            textView.textColor = UIColor.withHex("535376")
        }
    }
}


