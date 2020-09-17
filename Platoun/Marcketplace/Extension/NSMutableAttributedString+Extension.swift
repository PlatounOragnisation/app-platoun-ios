//
//  NSMutableAttributedString+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 22/04/2020.
//

import UIKit

extension NSMutableAttributedString {
    
    
    func bold(_ value:String, fontSize: CGFloat, color: UIColor? = nil) -> NSMutableAttributedString {

        var attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.helvetica(type: .bold, fontSize: fontSize)
        ]
        
        if let c = color {
            attributes[.foregroundColor] = c
        }

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String, fontSize: CGFloat) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.helvetica(type: .normal, fontSize: fontSize),
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
