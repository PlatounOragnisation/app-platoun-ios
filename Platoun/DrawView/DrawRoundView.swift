//
//  DrawRoundView.swift
//  Platoun
//
//  Created by Flavian Mary on 23/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol IDrawRoundView: UIView {
    var roundBackgroundColor: UIColor? { get set }
    var cornerRadius: CGFloat { get set }
}

extension IDrawRoundView {
    func drawRound(rect: CGRect, context: CGContext) {
        let path = UIBezierPath(
            roundedRect: self.bounds,
          byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: self.cornerRadius, height: self.cornerRadius)
        )
        path.addClip()
        
        if let color = roundBackgroundColor {
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
    }
}
