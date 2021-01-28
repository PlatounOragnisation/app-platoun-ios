//
//  UIViewController+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 01/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Bundle {
    static var platoun: Bundle {
        get {
//            let podBundle = Bundle(for: HttpServices.self)
//            let bundleURL = podBundle.url(forResource: "Platoun", withExtension: "bundle")
//            let bundle = Bundle(url: bundleURL!)!
            return Bundle.main
        }
    }
}

extension UIViewController {
    @objc static func instanceStoryboard() -> Self {        
        let t = "\(Self.self)".replacingOccurrences(of: "ViewController", with: "")
        let storyboard = UIStoryboard(name: t, bundle: Bundle.platoun)
        return storyboard.instantiateInitialViewController() as! Self
    }
}

extension String {
    func localise(_ value: Int? = nil) -> String {
        let text = NSLocalizedString(self, tableName: "Localization", bundle: Bundle.platoun, value: "**\(self)**", comment: "")
        
        guard let number = value else { return text }
        
        return String(format: text, number)
    }
}
