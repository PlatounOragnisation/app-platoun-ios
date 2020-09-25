//
//  CGContext+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 25/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

extension CGContext {
    func drawGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        let colors = colors.map { $0.cgColor }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                       colors: colors as CFArray,
                                    locations: nil)!
        self.drawLinearGradient(gradient,
                            start: startPoint,
                              end: endPoint,
                          options: [CGGradientDrawingOptions(rawValue: 0)])
    }
}
