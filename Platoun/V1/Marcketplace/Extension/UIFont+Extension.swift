//
//  UIFont+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 08/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

extension UIFont {
    enum BalooType: String {
        case regular = "Regular"
    }
    
    enum ArchivoBlackType: String {
        case regular = "Regular"
    }
    
    enum RobotoType: String {
        case black = "Black"
        case blackItalic = "BlackItalic"
        case medium = "Medium"
        case regular = "Regular"
    }
    
    enum HelveticaType: String {
        case normal = ""
        case ultraLightItalic = "UltraLightItalic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
        case ultraLight = "UltraLight"
        case italic = "Italic"
        case light = "Light"
        case thinItalic = "ThinItalic"
        case lightItalic = "LightItalic"
        case bold = "Bold"
        case thin = "Thin"
        case condensedBlack = "CondensedBlack"
        case condensedBold = "CondensedBold"
        case boldItalic = "BoldItalic"
    }
    
    static func helvetica(type: HelveticaType, fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue\(type != .normal ? "-" : "")\(type.rawValue)", size: fontSize)!
    }
    
    static func baloo(type: BalooType, fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Baloo-\(type.rawValue)", size: fontSize)!
    }
    
    static func roboto(type: RobotoType, fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-\(type.rawValue)", size: fontSize)!
    }
    
    static func archivoBlack(type: ArchivoBlackType, fontSize: CGFloat) -> UIFont {
        return UIFont(name: "ArchivoBlack-\(type.rawValue)", size: fontSize)!
    }
}
