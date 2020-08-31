//
//  LoginViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 23/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    static func show(in viewController: UIViewController, isForCredential: Bool = false, completionAuth: @escaping (Bool)->Void) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.completionAuth = completionAuth
        vc.isForCredential = isForCredential
        
        vc.modalPresentationStyle = .popover
        viewController.present(vc, animated: true)
        
    }
    
    var completionAuth: ((Bool)->Void)?
    
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var isForCredential: Bool = false
    
    lazy var firebaseUtils = FirebaseUtils(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        self.signUpButton.isHidden = isForCredential
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.completionAuth?(Auth.auth().currentUser != nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loginAction(sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        firebaseUtils.emailLogIn(withEmail: email, password: password, from: self, isForCredential: self.isForCredential)
    }
    
    @IBAction func SignUpAction(sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        firebaseUtils.emailSignUp(withEmail: email, password: password, from: self)
    }
    
    @IBAction func loginWithFacebook(sender: Any) {
        firebaseUtils.facebookLogIn(from: self, isForCredential: self.isForCredential)
    }
    
    @IBAction func loginWithGoogle(sender: Any) {
        firebaseUtils.googleSignIn(from: self, isForCredential: self.isForCredential)
    }
    
    @IBAction func loginWithApple(sender: Any) {
        firebaseUtils.appleLogIn(from: self, isForCredential: self.isForCredential)
    }
    
}

extension LoginViewController: FirebaseUtilsDelegate {
    func firebaseAuth(result: AuthDataResult) {
        if Auth.auth().currentUser != nil {
            print("Login successfuly")
            self.dismiss(animated: true)
        }
    }
    
    func firebaseAuthError(error: Error) {
        print("Login error: \(error.localizedDescription)")
    }
}
