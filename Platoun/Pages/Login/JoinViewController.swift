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
        pseudoTextFIeld.placeholder = "Pseaudo"
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
        self.signUp(with: .email(email: email, password: password))
    }
    
    private func signIn(with auth: Authentication) {
        auth.signIn(from: self, callBack: procedAfterAuth)
    }
    
    private func signUp(with auth: Authentication) {
        auth.signUp(from: self, callBack: procedAfterAuth)
    }
    
    private func procedAfterAuth(result: Result<AuthDataResult, Error>) {
        switch result {
        case .success:
            if let user = Auth.auth().currentUser {
                if user.isPassword {
                    let pseudo = pseudoTextFIeld.text ?? ""
                    self.createUserIfNeeded(user: user, name: pseudo) {
                        self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                    }
                } else {
                    if (user.displayName ?? "").isEmpty {
                        UIKitUtils.requestAlert(in: self, message: "Choissez un nom :") { name in
                            self.createUserIfNeeded(user: user, name: name) {
                                self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                            }
                        }
                    } else {
                        createUserIfNeeded(user: user, name: user.displayName!) {
                            self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                        }
                    }
                }
            }
        case .failure(let error):
            if case .cancelByUser = (error as? SignInError) {
                return
            }
            
            UIKitUtils.showAlert(in: self, message: "Register Error: \(error.localizedDescription)") {
                
            }
        }
    }
    
    private func createUserIfNeeded(user: User, name: String, completion: @escaping ()->Void) {
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
                
                let request = user.createProfileChangeRequest()
                request.displayName = name
                request.commitChanges {
                    if let error = $0 {
                        UIKitUtils.showAlert(in: self, message: "Une erreur est survenue lors du changement de votre nom : \(error.localizedDescription)") { }
                    }
                    let platounUser = PlatounUser(uid: user.uid, fcmToken: UserDefaults.standard.FCMToken, displayName: name, photoUrl: user.photoURL?.absoluteString, groupNotification: true, trendsNotification: true, newsNotification: true)
                    
                    
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
