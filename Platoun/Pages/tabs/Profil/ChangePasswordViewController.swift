//
//  ChangePasswordViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 31/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

extension UILabel {

    func applyGradientWith(startColor: UIColor, endColor: UIColor) -> Bool {

        var startColorRed:CGFloat = 0
        var startColorGreen:CGFloat = 0
        var startColorBlue:CGFloat = 0
        var startAlpha:CGFloat = 0

        if !startColor.getRed(&startColorRed, green: &startColorGreen, blue: &startColorBlue, alpha: &startAlpha) {
            return false
        }

        var endColorRed:CGFloat = 0
        var endColorGreen:CGFloat = 0
        var endColorBlue:CGFloat = 0
        var endAlpha:CGFloat = 0

        if !endColor.getRed(&endColorRed, green: &endColorGreen, blue: &endColorBlue, alpha: &endAlpha) {
            return false
        }

        let gradientText = self.text ?? ""

        let textSize: CGSize = gradientText.size(withAttributes: [.font:self.font!])
        let width:CGFloat = textSize.width
        let height:CGFloat = textSize.height

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return false
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
            return false
        }

        UIGraphicsEndImageContext()

        self.textColor = UIColor(patternImage: gradientImage)

        return true
    }

}

class ChangePasswordViewController: UIViewController {
    
    static func getInstance() -> ChangePasswordViewController {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        return vc
    }

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePreferredContentSize(with: self.traitCollection)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func forgotPassordAction(_ sender: Any) {
        Auth.auth().currentUser?.authentication?.resetPassword(from: self, callBack: { result in
            switch result {
            case .success():
                UIKitUtils.showAlert(in: self, message: "Le mail de réinitialisation de mot de passe à bien été envoyé.") {}
            case .failure(let error):
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenue : \(error.localizedDescription)") {}
            }
        })
    }
    
    @IBAction func saveNewPasswordAction(_ sender: Any) {
        let olPassword = oldPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !newPassword.isEmpty && newPassword == confirmPassword else {
            
            if newPassword.isEmpty {
                UIKitUtils.showAlert(in: self, message: "Le nouveau mot de passe ne peut pas être vide.") {}
            } else {
                UIKitUtils.showAlert(in: self, message: "Les deux nouveau mot de passe ne sont pas identique") {}
            }
            return
        }
        Auth.auth().currentUser?.authentication?.changePassword(from: self, olPassword: olPassword, newPassord: newPassword, callBack: { result in
            switch result {
            case .success():
                UIKitUtils.showAlert(in: self, message: "Votre mot de passe à bien été changé.") {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenue : \(error.localizedDescription)") {}
            }
        })
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updatePreferredContentSize(with: newCollection)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(
            width: self.view.bounds.size.width,
            height: traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact ? 334 : 520)
    }
}
