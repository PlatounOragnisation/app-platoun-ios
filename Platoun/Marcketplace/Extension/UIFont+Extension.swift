//
//  UIFont+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 08/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

extension UIFont {
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
}
