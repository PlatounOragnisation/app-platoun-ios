//
//  ParametersViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ParametersViewController: UIViewController {
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var changeValuesButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        
        changePasswordButton.isHidden = !(user?.isPassword ?? false)
        
        
        nickNameTextField.text = user?.displayName ?? ""
        emailTextField.text = user?.email ?? ""
        
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        let vc = ChangePasswordViewController.getInstance()
        
        let presentationController = CustomPresentationController(presentedViewController: vc, presenting: self)
        
//        vc.transitioningDelegate = presentationController
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func changeValuesAction(_ sender: Any) {
        self.updateName { nameChanged in
            self.updateEmail { emailChanged in
                var message: String = ""
                if nameChanged == true && emailChanged == true {
                    message = "Votre nom et votre email ont bien été changé."
                } else if nameChanged == true {
                    message = "Votre nom a bien été changé."
                } else if emailChanged == true {
                    message = "Votre email a bien été changé.\n"
                } else if nameChanged == false && emailChanged == false {
                    message = "Votre email et votre nom sont inchangé."
                }
                if message.isEmpty { return }
                UIKitUtils.showAlert(in: self, message: message) {
                    let user = Auth.auth().currentUser
                    self.nickNameTextField.text = user?.displayName ?? ""
                    self.emailTextField.text = user?.email ?? ""
                }
            }
        }
    }
    
    private func updateName(completion: @escaping (Bool?)->Void) {
        guard
            let user = Auth.auth().currentUser,
            let displayName = nickNameTextField.text,
            user.displayName != displayName else { completion(false); return }
        
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        request.commitChanges {
            if let error = $0 {
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenue lors du changement de votre nom : \(error.localizedDescription)") { completion(nil) }
            }
            completion(true)
        }
    }
    
    private func updateEmail(completion: @escaping (Bool?)->Void) {
        guard
            let user = Auth.auth().currentUser,
            let email = emailTextField.text,
            user.email != email else { completion(false); return }
        
        guard let authentication: Authentication = user.authentication else {
            return
        }
        
        authentication.reAuth(from: self) { authResult in
            switch authResult {
            case .success:
                user.updateEmail(to: email) {
                    if let error = $0 {
                        UIKitUtils.showAlert(in: self, message: "Une erreur est survenue lors du changement de votre email : \(error.localizedDescription)") { completion(nil) }
                    }
                    user.reload { e in
                        if let error = e {
                            UIKitUtils.showAlert(in: self, message: "Votre email a été changer mais une erreur est survenue après : \(error.localizedDescription)") { completion(nil) }
                        }
                        completion(true)
                    }
                }
            case .failure(let error):
                UIKitUtils.showAlert(in: self, message: "Un problème est survenue merci de vous reconnecter:\n\(error)") {
                    AuthenticationLogout()
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()
                }
            }
        }
    }
}
