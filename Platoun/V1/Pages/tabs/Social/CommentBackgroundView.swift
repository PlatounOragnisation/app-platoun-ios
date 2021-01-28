//
//  CommentBackgroundView.swift
//  Platoun
//
//  Created by Flavian Mary on 24/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class CommentBackgroundView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        context.drawGradient(
            colors: [ThemeColor.BackgroundGradient1, ThemeColor.BackgroundGradient2],
            startPoint: CGPoint(x: self.bounds.width*0.6, y: 0),
            endPoint: CGPoint(x: self.bounds.width, y: self.bounds.height*0.2))
        
        
        
        context.beginPath()
        let elipseRadius = (self.bounds.width*1.07)/2
        context.addEllipse(in: CGRect(
                            x: (self.bounds.width/2)-elipseRadius,
                            y: (self.bounds.width/2)-elipseRadius,
                            width: elipseRadius*2,
                            height: elipseRadius*2))
        context.move(to: CGPoint.zero)
        context.addLine(to: CGPoint(x: self.bounds.width*0.6, y: 0))
        context.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height*0.2))
        context.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        context.addLine(to: CGPoint(x: 0, y: self.bounds.height))
        context.addLine(to: CGPoint(x: 0, y: 0))
        context.closePath()
        
        context.clip()
        
        context.drawGradient(
            colors: [ThemeColor.BackgroundGradientCircle1, ThemeColor.BackgroundGradientCircle2],
            startPoint: CGPoint(x: self.bounds.minX, y: self.bounds.minY),
            endPoint: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        
        context.fillPath()
    }
}
