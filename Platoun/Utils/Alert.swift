//
//  Alert.swift
//  Platoun
//
//  Created by Flavian Mary on 31/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

struct AlertConfiguration {
    let title: String?
    let actions: [Action]
    
    struct Action {
        let title: String
        let action: (()->Void)?
        let color: UIColor?
        let style: UIAlertAction.Style
        
        fileprivate init(title: String, action: (()->Void)?, color: UIColor?, style: UIAlertAction.Style) {
            self.title = title
            self.action = action
            self.color = color
            self.style = style
        }
    }
    
    static var `default` = AlertConfiguration(
        title: nil,
        actions: [
            Alert.action(title: "OK".localise())
        ])
}

class Alert: NSObject {
    let message: String
    let configuration: AlertConfiguration
    
    static func action(title: String, color: UIColor? = nil, style: UIAlertAction.Style = .default, action: (()->Void)? = nil) -> AlertConfiguration.Action {
        return AlertConfiguration.Action(title: title, action: action, color: color, style: style)
    }
    
    init(show message: String, configuration: AlertConfiguration = AlertConfiguration.default) {
        self.message = message
        self.configuration = configuration
    }
    
    convenience init(show message: String, actions: [AlertConfiguration.Action]) {
        self.init(show: message, configuration: AlertConfiguration(title: nil, actions: actions))
    }
    
    func show(in viewController: UIViewController) {
        let alertController = UIAlertController(title: configuration.title, message: message, preferredStyle: .alert)
        
        
        configuration.actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in action.action?() }
            if let color = action.color {
                alertAction.setValue(color, forKey: "titleTextColor")
            }
            alertController.addAction(alertAction)
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}
