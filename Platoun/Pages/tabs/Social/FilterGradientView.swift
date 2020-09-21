//
//  FilterGradientView.swift
//  Platoun
//
//  Created by Flavian Mary on 21/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class FilterGradientView: UIView {
    
    
    let viewLabel = UILabel()
    let shadows = UIView()
    let layer0 = CALayer()
    let shapes = UIView()
    let layer1 = CALayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        viewLabel.backgroundColor = .clear

        shadows.frame = viewLabel.frame

        shadows.clipsToBounds = false

        if !viewLabel.subviews.contains(shadows) {
            viewLabel.addSubview(shadows)
        }


        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 12)
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = ThemeColor.Black.withAlphaComponent(0.25).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 4
        layer0.shadowOffset = CGSize(width: 0, height: 2)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        if !(shadows.layer.sublayers?.contains(layer0) ?? false) {
            shadows.layer.addSublayer(layer0)
        }

        shapes.frame = viewLabel.frame
        shapes.clipsToBounds = true
        if !viewLabel.subviews.contains(shapes) {
            viewLabel.addSubview(shapes)
        }


        layer1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        layer1.bounds = shapes.bounds
        layer1.position = shapes.center
        if !(shadows.layer.sublayers?.contains(layer1) ?? false) {
            shadows.layer.addSublayer(layer1)
        }

        shapes.layer.cornerRadius = 12

        if !self.subviews.contains(viewLabel) {
            self.insertSubview(viewLabel, at: 0)
        }
        self.viewLabel.layer.cornerRadius = 12
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer0.cornerRadius = 12
        self.layer1.cornerRadius = 12
//        self.shapes.layer.cornerRadius = 12

        viewLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
