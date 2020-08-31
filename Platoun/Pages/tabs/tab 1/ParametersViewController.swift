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
        
        
        nickNameTextField.text = user?.displayName ?? ""
        emailTextField.text = user?.email ?? ""
        
    }
    @IBAction func changePasswordAction(_ sender: Any) {
        let vc = ChangePasswordViewController.getInstance()
        
        let presentationController = CustomPresentationController(presentedViewController: vc, presenting: self)

        vc.transitioningDelegate = presentationController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func changeValuesAction(_ sender: Any) {
        self.updateName { nameChanged in
            self.updateEmail { emailChanged in
                var message: String = ""
                if nameChanged == true && emailChanged == true {
                    message = "Votre nom et votre email ont bien été changé."
                } else if nameChanged == true {
                    message = "Votre nom à bien été changé."
                } else if emailChanged == true {
                    message = "Votre email à bien été changé.\n"
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
        
        UIKitUtils.showAlert(in: self, message: "Pour modifier votre email vous devez vous réauthentifier") {
            LoginViewController.show(in: self, isForCredential: true, completionAuth: { isConnected in
                if isConnected {
                    user.updateEmail(to: email) {
                        if let error = $0 {
                            UIKitUtils.showAlert(in: self, message: "Une erreur est survenue lors du changement de votre email : \(error.localizedDescription)") { completion(nil) }
                        }
                        user.reload { e in
                            if let error = e {
                                UIKitUtils.showAlert(in: self, message: "Votre email à été changer mais une erreur est survenue après : \(error.localizedDescription)") { completion(nil) }
                            }
                            completion(true)
                        }
                    }
                }
            })
        }
    }
    
}

extension ParametersViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}



class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let containerView = self.containerView else { return CGRect.zero }
            return CGRect(x: 0, y: containerView.bounds.height/2, width: containerView.bounds.width, height: containerView.bounds.height/2)
        }
    }
}
