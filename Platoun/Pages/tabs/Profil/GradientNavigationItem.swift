//
//  NavigationBarTitleLabel.swift
//  Platoun
//
//  Created by Flavian Mary on 19/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class GradientNavigationItem: UINavigationItem {
    
    
    override var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.title
        label.font = UIFont(name: "Roboto-Bold", size: 20)
        return label
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleView = titleLabel
        if !self.titleLabel.applyGradientWith(startColor: ThemeColor.BackgroundGradient1, endColor: ThemeColor.BackgroundGradient2) {
            self.titleLabel.textColor = ThemeColor.BackgroundGradient2
        }
    }
}
