//
//  UIAlertViewController+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit


extension UIAlertController {
    
    static func askAuth(in viewController: UIViewController, completion: @escaping (Bool)->Void) -> UIAlertController {
        let vc = UIAlertController(title: "Attention", message: "Pour effectuer cette action vous devez être connecté !", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Je me connecte", style: .default, handler: { _ in
            LoginViewController.show(in: viewController, canCancel: true, completionAuth: completion)
        }))
        vc.addAction(UIAlertAction(title: "Pas pour le moment", style: .destructive, handler: nil))
        return vc

    }
    
    static func getFeatureAvailableSoon() -> UIAlertController {
        let vc = UIAlertController(title: "Prochainement", message: "Cette fonctionnalité sera prochainement disponible !", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return vc
    }
}
