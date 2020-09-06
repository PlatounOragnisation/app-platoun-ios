//
//  UIKitUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 31/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class UIKitUtils {
    static func showAlert(in viewControler: UIViewController, message: String, completion: @escaping ()->Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        viewControler.present(alert, animated: true, completion: nil)
    }
        
        
    static func showAlert(in viewControler: UIViewController, message: String, completionOK: @escaping ()->Void, completionCancel: @escaping ()->Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completionOK()
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { _ in
            completionCancel()
        }))
        viewControler.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(in viewControler: UIViewController, message: String, action1Title: String, completionOK: @escaping ()->Void, action2Title: String, completionCancel: @escaping ()->Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action1Title, style: .default, handler: { _ in
            completionOK()
        }))
        alert.addAction(UIAlertAction(title: action2Title, style: .cancel, handler: { _ in
            completionCancel()
        }))
        viewControler.present(alert, animated: true, completion: nil)
    }
    
}
