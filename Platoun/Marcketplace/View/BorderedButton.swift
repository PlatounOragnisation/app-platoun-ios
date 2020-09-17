//
//  BorderedButton.swift
//  Platoun
//
//  Created by Flavian Mary on 10/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButtonLocalized {
    
    @IBInspectable
    var hasShadow: Bool = false
    
    @IBInspectable
    var borderColor: UIColor = UIColor.white
    
    @IBInspectable
    var borderWidth: CGFloat = 2
    
    private var shadowLayer: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = bounds.height / 2
        self.layer.borderWidth = borderWidth
        
        if hasShadow && shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            layer.insertSublayer(shadowLayer!, at: 0)
        } else if !hasShadow {
            shadowLayer?.removeFromSuperlayer()
            shadowLayer = nil
        }
        
        
        if let shadowLayer = self.shadowLayer, hasShadow {
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.layer.cornerRadius).cgPath
            shadowLayer.fillColor = (self.backgroundColor ?? .white).cgColor
            
            shadowLayer.shadowColor = UIColor.rgb(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowLayer.shadowOpacity = 1
            shadowLayer.shadowRadius = 1
        }
    }
}
