//
//  ARSearch.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/4/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

class ARSearch: ARBorderedView {
    
    @IBOutlet weak var searchBar: UISearchBar!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI(name: self.nameOfClass)
    }
    
}
