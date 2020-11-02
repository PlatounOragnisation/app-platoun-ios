//
//  JoinViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 25/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class JoinViewController: UIViewController {
    
    var completionAuth: ((Bool)->Void)?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pseudoTextFIeld: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var seePasswordButton: UIButton!
    @IBOutlet weak var signUpButtonLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "S'inscrire"
        pseudoTextFIeld.placeholder = "Pseudo"
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Mot de passe"
        signUpButtonLabel.text = "Créer →"
        // Do any additional setup after loading the view.
        pseudoTextFIeld.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func seePasswordButtonAction(_ sender: Any) {
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        
        let image = self.passwordTextField.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eyes_close") : #imageLiteral(resourceName: "ic_eyes_open")
        seePasswordButton.setImage(image, for: .normal)
    }
    
    @IBAction func signInGoogle(_ sender: Any) {
        self.signIn(with: .google)
    }
    
    @IBAction func signInApple(_ sender: Any) {
        self.signIn(with: .apple)
    }
    
    @IBAction func signInFacebook(_ sender: Any) {
        self.signIn(with: .facebook)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let pseudo = pseudoTextFIeld.text ?? ""
        ManageUserUtils(in: self).nameIsOk(name: pseudo, attribuateName: false) { (nameValid, retry) in
            if nameValid {
                self.signUp(with: .email(email: email, password: password))
            }
        }
    }
    
    private func signIn(with auth: Authentication) {
        pseudoTextFIeld.text = ""
        auth.signIn(from: self, callBack: procedAfterAuth)
    }
    
    private func signUp(with auth: Authentication) {
        auth.signUp(from: self, callBack: procedAfterAuth)
    }
    
    
    
    private func procedAfterAuth(result: Result<AuthDataResult, Error>) {
        switch result {
        case .success:
            let pseudo = (pseudoTextFIeld.text ?? "").isEmpty ? nil : pseudoTextFIeld.text
            ManageUserUtils(in: self).afterCreation(name: pseudo) {
                self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
            }
        case .failure(let error):
            if case .cancelByUser = (error as? SignInError) {
                return
            }
            
            UIKitUtils.showAlert(in: self, message: "Register Error: \(error.localizedDescription)") {
                
            }
        }
    }
    
}

extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.pseudoTextFIeld {
            self.emailTextField.becomeFirstResponder()
        } else if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.passwordTextField.resignFirstResponder()
        }
        return true
    }
}
