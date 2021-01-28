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
    @IBOutlet weak var signUpGroup: UIView!
    @IBOutlet weak var signUpLoading: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "S'inscrire"
        pseudoTextFIeld.placeholder = "Nom d'utilisateur"
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Mot de passe"
        signUpButtonLabel.text = "Créer →"
        // Do any additional setup after loading the view.
        pseudoTextFIeld.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        signUpGroup.isHidden = false
        signUpLoading.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.bottomConstraint.constant = 0.0
            } else {
                self.bottomConstraint.constant = -(endFrame?.size.height ?? 0.0) + ( self.tabBarController?.tabBar.frame.size.height ?? 0.0)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil
            )
        }
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
        self.signUpGroup.isHidden = true
        self.signUpLoading.isHidden = false
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let pseudo = pseudoTextFIeld.text ?? ""
        ManageUserUtils(in: self).nameIsOk(name: pseudo, attribuateName: false) { (nameValid, retry) in
            if nameValid {
                self.signUp(with: .email(email: email, password: password))
            } else {
                self.signUpGroup.isHidden = false
                self.signUpLoading.isHidden = true
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
            self.signUpGroup.isHidden = false
            self.signUpLoading.isHidden = true
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
