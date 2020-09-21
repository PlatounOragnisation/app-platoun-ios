//
//  GradientUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 20/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

extension UIView {
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        if self.layer.sublayers?.first is CAGradientLayer {
            self.layer.sublayers?.first?.removeFromSuperlayer()
        }
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

extension UILabel {
    
    fileprivate func getPatternImage(startColor: UIColor, endColor: UIColor)-> UIImage? {
        var startColorRed:CGFloat = 0
        var startColorGreen:CGFloat = 0
        var startColorBlue:CGFloat = 0
        var startAlpha:CGFloat = 0

        if !startColor.getRed(&startColorRed, green: &startColorGreen, blue: &startColorBlue, alpha: &startAlpha) {
            return nil
        }

        var endColorRed:CGFloat = 0
        var endColorGreen:CGFloat = 0
        var endColorBlue:CGFloat = 0
        var endAlpha:CGFloat = 0

        if !endColor.getRed(&endColorRed, green: &endColorGreen, blue: &endColorBlue, alpha: &endAlpha) {
            return nil
        }

        let gradientText = self.text ?? ""

        let textSize: CGSize = gradientText.size(withAttributes: [.font:self.font!])
        let width:CGFloat = textSize.width
        let height:CGFloat = textSize.height

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        UIGraphicsPushContext(context)

        let glossGradient:CGGradient?
        let rgbColorspace:CGColorSpace?
        let num_locations:size_t = 2
        let locations:[CGFloat] = [ 0.0, 1.0 ]
        let components:[CGFloat] = [startColorRed, startColorGreen, startColorBlue, startAlpha, endColorRed, endColorGreen, endColorBlue, endAlpha]
        rgbColorspace = CGColorSpaceCreateDeviceRGB()
        glossGradient = CGGradient(colorSpace: rgbColorspace!, colorComponents: components, locations: locations, count: num_locations)
        let topCenter = CGPoint.zero
        let bottomCenter = CGPoint(x: 0, y: textSize.height)
        context.drawLinearGradient(glossGradient!, start: topCenter, end: bottomCenter, options: CGGradientDrawingOptions.drawsBeforeStartLocation)

        UIGraphicsPopContext()

        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        UIGraphicsEndImageContext()
        return gradientImage
    }
    
    @discardableResult
    func applyGradientWith(startColor: UIColor, endColor: UIColor) -> Bool {

        guard let gradientImage = self.getPatternImage(startColor: startColor, endColor: endColor) else { return false }

        self.textColor = UIColor(patternImage: gradientImage)

        return true
    }

}

extension UIButton {
    
    @discardableResult
    func applyGradientWith(startColor: UIColor, endColor: UIColor) -> Bool {

        guard let label = self.titleLabel, let gradientImage = label.getPatternImage(startColor: startColor, endColor: endColor) else { return false }

        self.setTitleColor(UIColor(patternImage: gradientImage), for: .normal)

        return true
    }

}
