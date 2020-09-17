//
//  RotatedLabel.swift
//  Platoun
//
//  Created by Flavian Mary on 13/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

@IBDesignable
class RotatedLabel: UILabel {
    
    @IBInspectable
    var angle: CGFloat = 0
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.transform = CGAffineTransform(rotationAngle: angle.radian)
    }
}
