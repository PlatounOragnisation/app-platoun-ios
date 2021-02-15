//
//  UIAlertViewController+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit


extension UIAlertController {
    
    static func getFeatureAvailableSoon() -> UIAlertController {
        let vc = UIAlertController(title: "Prochainement", message: "Cette fonctionnalité sera prochainement disponible !", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return vc
    }
}
