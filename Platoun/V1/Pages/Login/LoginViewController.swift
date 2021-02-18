//
//  LoginViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 23/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    static func show(in viewController: UIViewController, isForCredential: Bool = false, canCancel: Bool = false, completionAuth: @escaping (Bool)->Void) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.completionAuth = completionAuth
        let nav = UINavigationController(rootViewController: vc)
        if #available(iOS 13.0, *) {
            nav.isModalInPresentation = !canCancel
        }
        nav.navigationBar.isHidden = true
        viewController.present(nav, animated: true)

    }
    
    var completionAuth: ((Bool)->Void)?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var seePasswordButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var signInButtonLabel: UILabel!
    @IBOutlet weak var signUpButtonLabel: UILabel!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBAction func seePasswordButtonAction(_ sender: Any) {
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        
        let image = self.passwordTextField.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eyes_close") : #imageLiteral(resourceName: "ic_eyes_open")
        seePasswordButton.setImage(image, for: .normal)
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        if seg.source is ForgotPasswordViewController { return }
        self.exit(creation: true)
    }
    
    func exit(creation: Bool) {
        if creation && Auth.auth().currentUser == nil { return }
        
        self.completionAuth?(Auth.auth().currentUser != nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Se connecter"
        self.emailTextField.placeholder = "Email"
        self.passwordTextField.placeholder = "Mot de passe"
        signInButtonLabel.text = "Connexion →"
        signUpButtonLabel.text = "Créer un compte"
        forgotButton.setTitle("Mot de passe oublié ?", for: .normal)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
        
    @IBAction func loginAction(sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        self.signIn(with: .email(email: email, password: password))
    }
    
    @IBAction func loginWithFacebook(sender: Any) {
        self.signIn(with: .facebook)
    }
    
    @IBAction func loginWithGoogle(sender: Any) {
        self.signIn(with: .google)
    }
    
    @IBAction func loginWithApple(sender: Any) {
        self.signIn(with: .apple)
    }
    
    
    private func signIn(with auth: Authentication) {
        auth.signIn(from: self, callBack: procedAfterAuth)
    }
        
    private func procedAfterAuth(result: Result<AuthDataResult, Error>) {
        switch result {
        case .success:
            ManageUserUtils(in: self).afterConnexion() {
                self.exit(creation: false)
            }
        case .failure(let error):
            if case .cancelByUser = (error as? SignInError) {
                return
            }
            
            UIKitUtils.showAlert(in: self, message: "Login Error: \(error.localizedDescription)") {
                
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
