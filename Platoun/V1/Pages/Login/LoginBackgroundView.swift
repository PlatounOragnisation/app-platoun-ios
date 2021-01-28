//
//  LoginBackgroundView.swift
//  Platoun
//
//  Created by Flavian Mary on 25/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class LoginBackgroundView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        context.drawGradient(
            colors: [ThemeColor.BackgroundGradient1, ThemeColor.BackgroundGradient2],
            startPoint: CGPoint(x: self.bounds.width*0.5, y: 0),
            endPoint: CGPoint(x: self.bounds.width, y: self.bounds.height*0.5))
        
        context.drawGradient(
            colors: [ThemeColor.BackgroundGradient1, ThemeColor.BackgroundGradient2],
            startPoint: CGPoint(x: self.bounds.width, y: self.bounds.height*0.5),
            endPoint: CGPoint(x: 0, y: self.bounds.height))
        
        let diameter = (self.bounds.width*2.0)
        let bezier = UIBezierPath(
            ovalIn: CGRect(
                x: -(diameter*0.48),
                y: -(diameter*0.08),
                width: diameter,
                height: diameter))
        
        ThemeColor.White.setFill()
        bezier.fill()
    }
}
