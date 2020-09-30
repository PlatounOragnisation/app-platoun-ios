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
    
    static func show(in viewController: UIViewController, isForCredential: Bool = false, completionAuth: @escaping (Bool)->Void) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.completionAuth = completionAuth
        let nav = UINavigationController(rootViewController: vc)
        if #available(iOS 13.0, *) {
            nav.isModalInPresentation = true
        }
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .popover
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
            if let user = Auth.auth().currentUser {
                createUserIfNeeded(user: user) {
                    self.exit(creation: false)
                }
            }
        case .failure(let error):
            if case .cancelByUser = (error as? SignInError) {
                return
            }
            
            UIKitUtils.showAlert(in: self, message: "Login Error: \(error.localizedDescription)") {
                
            }
        }
    }
    
    private func createUserIfNeeded(user: User, completion: @escaping ()->Void) {
        FirestoreUtils.getUser(uid: user.uid) { result in
            switch result {
            case .success(let user):
                if let fcmToken = UserDefaults.standard.FCMToken {
                    Interactor.shared.updateToken(userId: user.uid, token: fcmToken)
                    if fcmToken != user.fcmToken {
                        FirestoreUtils.saveUser(uid: user.uid, fcmToken: fcmToken)
                    }
                }
                completion()
            case .failure(let error):
            
                guard case .noErrorGetUser(let uid) = (error as? FirestoreUtilsError), uid == user.uid else {
                    Auth.auth().currentUser?.delete()
                    AuthenticationLogout()
                    UIKitUtils.showAlert(in: self, message: "Une erreur est survenue durant la créeation de votre profil, merci de réessayer.") {}
                    return
                }
                
                let platounUser = PlatounUser(uid: user.uid, fcmToken: UserDefaults.standard.FCMToken, displayName: user.displayName, photoUrl: user.photoURL?.absoluteString, groupNotification: true, trendsNotification: true, newsNotification: true)
                
                
                FirestoreUtils.createUser(user: platounUser) { r in
                    switch r {
                    case .success:
                        completion()
                    case .failure:
                        Auth.auth().currentUser?.delete()
                        AuthenticationLogout()
                        UIKitUtils.showAlert(in: self, message: "Une erreur est survenue durant la créeation de votre profil, merci de réessayer.") {}
                    }
                }
                Interactor.shared.updateToken(userId: user.uid, token: UserDefaults.standard.FCMToken ?? "")
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
