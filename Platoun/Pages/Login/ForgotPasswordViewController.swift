//
//  ForgotPasswordViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 25/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButtonLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Mot de passe oublié"
        detailLabel.text = "Entre ton adresse email, nous allons te renvoyer ton mot de passe."
        emailTextField.placeholder = "Email"
        sendButtonLabel.text = "Envoyer →"
        // Do any additional setup after loading the view.
    }
    @IBAction func sendEmailAction(_ sender: Any) {
        guard let email = self.emailTextField.text else { return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let err = error {
                Crashlytics.crashlytics().record(error: err)
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenu") {}
            } else {
                UIKitUtils.showAlert(in: self, message: "Un email a été envoyer") {
                    self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                }
            }
        }
    }
}
