//
//  DrawBackgroundView.swift
//  Platoun
//
//  Created by Flavian Mary on 23/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class DrawBackgroundView: UIView, IDrawGradientView, IDrawRoundView, IDrawShadowView {
    
    
    
    @IBInspectable var startColor: UIColor = ThemeColor.White
    @IBInspectable var endColor: UIColor = ThemeColor.White
    @IBInspectable var startPointX: CGFloat = 0
    @IBInspectable var startPointY: CGFloat = 0
    @IBInspectable var endPointX: CGFloat = 0
    @IBInspectable var endPointY: CGFloat = 0
    
    var roundBackgroundColor: UIColor? = nil
    @IBInspectable var cornerRadius: CGFloat = 0
    
    
    @IBInspectable var shadowColor: UIColor = ThemeColor.Black
    @IBInspectable var shadowColorAlpha: CGFloat = 100
    @IBInspectable var shadowBlur: CGFloat = 0
    @IBInspectable var shadowOffsetWidth: CGFloat = 0
    @IBInspectable var shadowOffsetHeight: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        self.drawRound(rect: rect, context: context)
        self.drawGradient(context: context)
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        self.drawShadow(layer)
    }
}
