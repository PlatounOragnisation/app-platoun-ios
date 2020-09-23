//
//  CellGradientView.swift
//  Platoun
//
//  Created by Flavian Mary on 22/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class CellGradientView: UIView {
    
    
    var shadows = UIView()
    var shadowPath0: UIBezierPath?
    var shapes = UIView()
    var layer0 = CALayer()

    let layer1 = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        let frame = CGRect(x: 16, y: 16, width: self.frame.width-32, height: self.frame.height-32)
        let frameZero = CGRect(x: 0, y: 0, width: self.frame.width-32, height: self.frame.height-32)

        shadows.clipsToBounds = false
        shadows.frame = frameZero

        if !self.subviews.contains(shadows) {
            self.insertSubview(shadows, at: 0)
        }


        shadowPath0 = UIBezierPath(roundedRect: frame, cornerRadius: 25)

        layer0.shadowPath = shadowPath0!.cgPath

        layer0.shadowColor = ThemeColor.DrakGrey.withAlphaComponent(0.25).cgColor

        layer0.shadowOpacity = 1

        layer0.shadowRadius = 14

        layer0.shadowOffset = CGSize(width: 0, height: 1)

        layer0.bounds = shadows.bounds

        layer0.position = shadows.center

        if !(shadows.layer.sublayers?.contains(layer0) ?? false) {
            shadows.layer.addSublayer(layer0)
        }

        shapes.frame = frame

        shapes.clipsToBounds = true

        if !self.subviews.contains(shapes) {
            self.insertSubview(shapes, at: 1)
        }


        layer1.colors = [ThemeColor.White.cgColor, ThemeColor.F7F6FB.cgColor]

        layer1.locations = [0, 1]

        layer1.startPoint = CGPoint(x: 0.25, y: 0.5)

        layer1.endPoint = CGPoint(x: 0.75, y: 0.5)

        layer1.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))

        layer1.bounds = shapes.bounds.insetBy(dx: -0.5*shapes.bounds.size.width, dy: -0.5*shapes.bounds.size.height)

        layer1.position = shapes.center

        if !(shapes.layer.sublayers?.contains(layer1) ?? false) {
//            shapes.layer.addSublayer(layer1)
        }

        shapes.layer.cornerRadius = 25

    }
    
}
