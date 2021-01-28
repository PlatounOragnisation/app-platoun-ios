//
//  CellGradientView.swift
//  Platoun
//
//  Created by Flavian Mary on 22/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol IDrawGradientView: UIView {
    var startColor: UIColor { get set }
    var endColor: UIColor { get set }
    
    var startPointX: CGFloat { get set }
    var startPointY: CGFloat { get set }
    var endPointX: CGFloat { get set }
    var endPointY: CGFloat { get set }
}

extension IDrawGradientView {
    func drawGradient(context: CGContext, stpt: CGPoint? = nil, enpt: CGPoint? = nil) {
        let colors = [startColor.cgColor, endColor.cgColor]

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let colorLocations: [CGFloat] = [0.0, 1.0]

        let gradient = CGGradient(colorsSpace: colorSpace,
                                       colors: colors as CFArray,
                                    locations: colorLocations)!

        let sX = startPointX == -1 ? bounds.width : startPointX
        let sY = startPointY == -1 ? bounds.height : startPointY
        let eX = endPointX == -1 ? bounds.width : endPointX
        let eY = endPointY == -1 ? bounds.height : endPointY
        
        
        let startPoint = CGPoint(x: sX, y: sY)
        let endPoint = CGPoint(x: eX, y: eY)
        context.drawLinearGradient(gradient,
                            start: stpt ?? startPoint,
                              end: enpt ?? endPoint,
                          options: [CGGradientDrawingOptions(rawValue: 0)])
    }
}
