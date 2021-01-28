//
//  FilterGradientView.swift
//  Platoun
//
//  Created by Flavian Mary on 21/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class FilterGradientView: UIView, IDrawRoundView, IDrawShadowView, IDrawGradientView {
    var startColor: UIColor = .white
    var endColor: UIColor = .white
    var startPointX: CGFloat = -1
    var startPointY: CGFloat = 0
    var endPointX: CGFloat = 0
    var endPointY: CGFloat = -1
    
    var roundBackgroundColor: UIColor? = ThemeColor.White
    var cornerRadius: CGFloat = 12
    
    var shadowColor: UIColor = ThemeColor.Black
    var shadowColorAlpha: CGFloat = 10
    var shadowBlur: CGFloat = 4
    var shadowOffsetWidth: CGFloat = 0
    var shadowOffsetHeight: CGFloat = 0
    
    
    private(set) var isSelected: Bool = false
    weak var labelConnected: UILabel?
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        self.drawRound(rect: rect, context: context)
        self.drawGradient(context: context)
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        if !isSelected {
            self.drawShadow(layer)
        }
    }
    
    func set(isSelected: Bool) {
        guard isSelected != self.isSelected else { return }
        self.isSelected = isSelected
        startColor = isSelected ? ThemeColor.BackgroundGradient2 : ThemeColor.White
        endColor = isSelected ? ThemeColor.BackgroundGradient1 : ThemeColor.White
        
        self.labelConnected?.textColor = isSelected ? ThemeColor.White : ThemeColor.Black

        self.setNeedsDisplay()
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        viewLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
//        viewLabel.backgroundColor = .clear
//
//        shadows.frame = viewLabel.frame
//
//        shadows.clipsToBounds = false
//
//        if !viewLabel.subviews.contains(shadows) {
//            viewLabel.addSubview(shadows)
//        }
//
//
//        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 12)
//        layer0.shadowPath = shadowPath0.cgPath
//        layer0.shadowColor = ThemeColor.Black.withAlphaComponent(0.25).cgColor
//        layer0.shadowOpacity = 1
//        layer0.shadowRadius = 4
//        layer0.shadowOffset = CGSize(width: 0, height: 2)
//        layer0.bounds = shadows.bounds
//        layer0.position = shadows.center
//        if !(shadows.layer.sublayers?.contains(layer0) ?? false) {
//            shadows.layer.addSublayer(layer0)
//        }
//
//        shapes.frame = viewLabel.frame
//        shapes.clipsToBounds = true
//        if !viewLabel.subviews.contains(shapes) {
//            viewLabel.addSubview(shapes)
//        }
//
//
//        layer1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
//        layer1.bounds = shapes.bounds
//        layer1.position = shapes.center
//        if !(shadows.layer.sublayers?.contains(layer1) ?? false) {
//            shadows.layer.addSublayer(layer1)
//        }
//
//        shapes.layer.cornerRadius = 12
//
//        if !self.subviews.contains(viewLabel) {
//            self.insertSubview(viewLabel, at: 0)
//        }
//        self.viewLabel.layer.cornerRadius = 12
//        self.backgroundColor = .clear
//        self.layer.cornerRadius = 12
//        self.layer0.cornerRadius = 12
//        self.layer1.cornerRadius = 12
////        self.shapes.layer.cornerRadius = 12
//
//        viewLabel.translatesAutoresizingMaskIntoConstraints = false
//        viewLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        viewLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        viewLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        viewLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//    }
    
}
