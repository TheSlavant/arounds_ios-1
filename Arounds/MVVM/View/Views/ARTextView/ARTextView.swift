//
//  ARTextView.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import KMPlaceholderTextView
import UIKit

@IBDesignable
class ARTextView: ARBorderedView  {
   
    var didClickText:((String)-> Void)?

    var text = "" {
        didSet{
            if  text.count > 0 {
                textView.text = text
            }
            rangeLabel.text = "\(textView.text.count)/\(max)"
        }
    }
    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var rangeLabel: UILabel!

    
    @IBInspectable var max: Int = 100
    @IBInspectable var placeholder: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI(name: self.nameOfClass)
        textView.delegate = self
        if  text.count > 0 {
            textView.text = text
        }
        rangeLabel.text = "\(textView.text.count)/\(max)"
        textView.placeholder = placeholder
    }
    
    func clear() {
        textView.text = ""
        rangeLabel.text = "\(0)/\(max)"
    }
}

extension ARTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.didClickText?(textView.text)
        }

        let count = textView.text.count
        //
        if text != "" && count >= max {
            return false
        }
        //
        let characterCount = text == "" ? count - 1 : count + text.count
        rangeLabel.text = "\(characterCount < 0 ? 0 : characterCount)/\(max)"
        return true
    }
    
}


