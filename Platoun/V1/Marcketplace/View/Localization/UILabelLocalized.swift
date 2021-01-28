//
//  UILabelLocalized.swift
//  Platoun
//
//  Created by Flavian Mary on 12/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class UILabelLocalized: UILabel {
    
    @IBInspectable
    var localizedText: String? {
        didSet {
            self.text = isLocalized ? localizedText?.localise() : localizedText
        }
    }
    
    var isLocalized = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if isLocalized && self.localizedText?.isEmpty ?? true {
            self.localizedText = "No localization key"
        }
    }
}

class UINavigationItemLocalized: UINavigationItem {
    @IBInspectable
    var localizedTitle: String? {
        didSet {
            self.title = localizedTitle?.localise()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if self.localizedTitle?.isEmpty ?? true {
            self.title = "**No localization key**"
        }
    }
}

class UIButtonLocalized: UIButton {
    @IBInspectable
    var localizedTitle: String? {
        didSet {
            self.setTitle(localizedTitle?.localise(), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if self.localizedTitle?.isEmpty ?? true {
            self.setTitle("**No localization key**", for: .normal)
        }
    }
}
