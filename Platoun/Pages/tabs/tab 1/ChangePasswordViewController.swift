//
//  ChangePasswordViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 31/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

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
