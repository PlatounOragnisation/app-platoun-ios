//
//  RoundedView.swift
//  Platoun
//
//  Created by Flavian Mary on 22/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat = -1
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius == -1 ? self.frame.height / 2 : cornerRadius
        self.layer.masksToBounds = true
    }
}
