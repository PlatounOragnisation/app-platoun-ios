//
//  DrawShadowView.swift
//  Platoun
//
//  Created by Flavian Mary on 23/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol IDrawShadowView: UIView {
    var shadowColor: UIColor { get set }
    var shadowColorAlpha: CGFloat { get set }
    var shadowBlur: CGFloat { get set }
    var shadowOffsetWidth: CGFloat { get set }
    var shadowOffsetHeight: CGFloat { get set }
}

extension IDrawShadowView {
        
    func drawShadow(_ layer: CALayer? = nil) {
        (layer ?? self.layer).shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: (self as? IDrawRoundView)?.cornerRadius ?? 0
        ).cgPath
        (layer ?? self.layer).shadowRadius = self.shadowBlur
        (layer ?? self.layer).shadowColor = self.shadowColor.withAlphaComponent(self.shadowColorAlpha / 100).cgColor
        (layer ?? self.layer).shadowOffset = CGSize(
            width: shadowOffsetWidth,
            height: shadowOffsetHeight
        )
        (layer ?? self.layer).shadowOpacity = 1
    }
}
