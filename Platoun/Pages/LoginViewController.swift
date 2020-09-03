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

        vc.modalPresentationStyle = .popover
        viewController.present(vc, animated: true)

    }
    
    var completionAuth: ((Bool)->Void)?
    
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
            
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.signUpButton.isHidden = isForCredential
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.completionAuth?(Auth.auth().currentUser != nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loginAction(sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        self.signIn(with: .email(email: email, password: password))
    }
    
    @IBAction func SignUpAction(sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""        
        self.signUp(with: .email(email: email, password: password))
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
    
    private func signUp(with auth: Authentication) {
        auth.signUp(from: self, callBack: procedAfterAuth)
    }
    
    private func procedAfterAuth(result: Result<AuthDataResult, Error>) {
        switch result {
        case .success:
            if Auth.auth().currentUser != nil {
                self.dismiss(animated: true)
            }
        case .failure(let error):
            UIKitUtils.showAlert(in: self, message: "Login Error: \(error.localizedDescription)") {
                if (error as? AuthenticationError) == AuthenticationError.cancel {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
}

//extension LoginViewController: FirebaseUtilsDelegate {
//    func firebaseAuth(result: AuthDataResult) {
//        if Auth.auth().currentUser != nil {
//            print("Login successfuly")
//            self.dismiss(animated: true)
//        }
//    }
//
//    func firebaseAuthError(error: Error) {
//        print("Login error: \(error.localizedDescription)")
//    }
//}
