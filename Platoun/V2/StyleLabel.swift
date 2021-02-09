//
//  StyleLabel.swift
//  Platoun
//
//  Created by Flavian Mary on 01/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit


class StyleLabel: UILabel {
    
    private var colors: [UIColor] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }
    
    func update(colors: [UIColor]) {
        self.colors = colors
        self.resetGradient()
    }
    
    func initialize() {
        self.resetGradient()
    }
    
    func resetGradient() {
        if !self.frame.equalTo(CGRect.zero) {
            guard let img = self.gradientImage(with: self.colors, size: self.frame.size) else { return }
            self.textColor = UIColor(patternImage: img)
        }
    }
    
    func gradientImage(with colors:[UIColor], size: CGSize) -> UIImage? {
        let width = size.width
        let height = size.height
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        UIGraphicsPushContext(context)
        
        var locations = [CGFloat]()
        
        for i in 0..<colors.count {
            locations.insert(CGFloat(i) / CGFloat(colors.count - 1), at: i)
        }
                
        
        var components = [CGFloat]()
        
        for i in 0..<(colors.count) {
            let color = colors[i]
            components.insert(color.rgba.red, at: 4*i+0)
            components.insert(color.rgba.green, at: 4*i+1)
            components.insert(color.rgba.blue, at: 4*i+2)
            components.insert(color.rgba.alpha, at: 4*i+3)
        }
        
        let rgbColorspace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorSpace: rgbColorspace, colorComponents: components, locations: locations, count: colors.count) else { return nil }
        
        let topCenter = CGPoint.zero
        let bottomCenter = CGPoint(x: 0, y: height)
        
        context.drawLinearGradient(gradient, start: topCenter, end: bottomCenter, options: CGGradientDrawingOptions())
                
        UIGraphicsPopContext()
        
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return gradientImage
    }
}
