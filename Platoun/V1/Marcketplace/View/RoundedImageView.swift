//
//  RoundedView.swift
//  Platoun
//
//  Created by Flavian Mary on 22/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    
    @IBInspectable
    var isShadowed: Bool = false
    
    @IBInspectable
    var isCircle: Bool = true
    
    @IBInspectable
    var cornerRadius: CGFloat = 0.0
    
    private var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.isCircle ? self.frame.height / 2 : cornerRadius
//        self.layer.masksToBounds = true
        
        if isShadowed && shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            layer.insertSublayer(shadowLayer!, at: 0)
        } else if !isShadowed {
            shadowLayer?.removeFromSuperlayer()
            shadowLayer = nil
        }
        
        
        if let shadowLayer = self.shadowLayer, isShadowed {
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.layer.cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor
            
            shadowLayer.shadowColor = UIColor.rgb(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowLayer.shadowOpacity = 1
            shadowLayer.shadowRadius = 1
        }
    }
}
