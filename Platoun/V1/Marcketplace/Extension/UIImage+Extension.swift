//
//  UIImage+Extension.swift
//  Alamofire
//
//  Created by Flavian Mary on 15/04/2020.
//

import UIKit

extension UIImage {
    
    convenience init?(named: String) {
        self.init(named: named, in: Bundle.platoun, compatibleWith: nil)
    }
}
