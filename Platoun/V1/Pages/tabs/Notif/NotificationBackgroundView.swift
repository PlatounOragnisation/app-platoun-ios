//
//  NotificationBackgroundView.swift
//  Platoun
//
//  Created by Flavian Mary on 30/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class NotificationBackgroundView: UIView, IDrawGradientView, IDrawShadowView, IDrawRoundView {
    var startColor: UIColor = ThemeColor.c038091
    var endColor: UIColor = ThemeColor.c00C5AE
    var startPointX: CGFloat = 0
    var startPointY: CGFloat = -1
    var endPointX: CGFloat = -1
    var endPointY: CGFloat = 0
    var shadowColor: UIColor = ThemeColor.Black
    var shadowColorAlpha: CGFloat = 25
    var shadowBlur: CGFloat = 4
    var shadowOffsetWidth: CGFloat = 0
    var shadowOffsetHeight: CGFloat = 0
    var roundBackgroundColor: UIColor?
    var cornerRadius: CGFloat = 12
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = .clear
        let context = UIGraphicsGetCurrentContext()!
        self.drawRound(rect: rect, context: context)
        self.drawGradient(context: context)
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        self.drawShadow(layer)
    }
    
}
