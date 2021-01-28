//
//  GradientButton.swift
//  Platoun
//
//  Created by Flavian Mary on 20/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class GradientButton: UIButton {
    
    @IBInspectable
    var startColor: UIColor = .white
    
    @IBInspectable
    var endColor: UIColor = .black
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyGradientWith(startColor: startColor, endColor: endColor)
    }
}
