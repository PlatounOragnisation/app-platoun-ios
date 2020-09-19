//
//  ParametersViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics

extension UIView {
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

fileprivate extension UIButton {
    enum ButtonPage {
        case value, password, account
    }
    
    func round(type: ButtonPage) {
        
        switch type {
        case .value:
            self.backgroundColor = ThemeColor.White
            self.setTitleColor(ThemeColor.White, for: .normal)
            self.applyGradient(
                colours: [
                    ThemeColor.BackgroundGradient1,
                    ThemeColor.BackgroundGradient2
            ])
        case .password:
            self.backgroundColor = ThemeColor.BackgroundButton
            self.setTitleColor(ThemeColor.White, for: .normal)
        case .account:
            self.backgroundColor = ThemeColor.BackgroundButton
            self.setTitleColor(ThemeColor.GreyText, for: .normal)
        }
        
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = ThemeColor.White.cgColor
        self.layer.masksToBounds = true
    }
}


class ParametersViewController: UIViewController {
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var changeValueContainer: UIView!
    @IBOutlet weak var changeValuesButton: UIButton!
    @IBOutlet weak var changePasswordContainer: UIView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var notifCategory1Container: UIView!
    @IBOutlet weak var notifCategory1Label: UILabel!
    @IBOutlet weak var notifCategory1Switch: CustomSwitch!
    @IBOutlet weak var notifCategory2Container: UIView!
    @IBOutlet weak var notifCategory2Label: UILabel!
    @IBOutlet weak var notifCategory2Switch: CustomSwitch!
    @IBOutlet weak var notifCategory3Container: UIView!
    @IBOutlet weak var notifCategory3Label: UILabel!
    @IBOutlet weak var notifCategory3Switch: CustomSwitch!
    @IBOutlet weak var removeAccountButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        
        self.navigationItem.title = "Paramètres"
        self.changeValuesButton.setTitle("Valider le changement", for: .normal)
        self.changePasswordButton.setTitle("Modifier Mot de passe", for: .normal)
        self.removeAccountButton.setTitle("Supprimer mon compte", for: .normal)
        self.notificationsLabel.text = "Notifications"
        self.notifCategory1Label.text = "Activités liés à mes groupes"
        self.notifCategory2Label.text = "Publications Tendances"
        self.notifCategory3Label.text = "Dernières nouveautés sur l’app"
        
        
        self.notifCategory1Switch.isUserInteractionEnabled = false
        self.notifCategory2Switch.isUserInteractionEnabled = false
        self.notifCategory3Switch.isUserInteractionEnabled = false
        
        self.notifCategory1Container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clickCategory1Container)))
        self.notifCategory2Container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clickCategory2Container)))
        self.notifCategory3Container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clickCategory3Container)))
        
        
        self.changeValuesButton.round(type: .value)
        self.changeValueContainer.isHidden = true
        
        self.nickNameTextField.delegate = self
        self.emailTextField.delegate = self
        
        let user = Auth.auth().currentUser
        
        changePasswordContainer.isHidden = !(user?.isPassword ?? false)
        self.changePasswordButton.round(type: .password)

        self.removeAccountButton.round(type: .account)
        
        nickNameTextField.placeholder = "Prénom"
        emailTextField.placeholder = "Adresse email"
        
        
        nickNameTextField.text = user?.displayName ?? ""
        emailTextField.text = user?.email ?? ""
        
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
    
    @objc func clickCategory1Container() {
        self.notifCategory1Switch.setOn(on: !self.notifCategory1Switch.isOn, animated: true)
    }
    
    @objc func clickCategory2Container() {
        self.notifCategory2Switch.setOn(on: !self.notifCategory2Switch.isOn, animated: true)
    }
    
    @objc func clickCategory3Container() {
        self.notifCategory3Switch.setOn(on: !self.notifCategory3Switch.isOn, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        let vc = ChangePasswordViewController.getInstance()
        
        let presentationController = CustomPresentationController(presentedViewController: vc, presenting: self)
        
        vc.transitioningDelegate = presentationController
//        vc.modalPresentationStyle = .popover
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
    @IBAction func removeAccountAction(_ sender: Any) {
        UIKitUtils.showAlert(in: self, message: "Êtes-vous sur de vouloir supprimer votre compte ?", action1Title: "Oui", completionOK: {
            let user = Auth.auth().currentUser
            user?.delete { error in
              if let error = error {
                Crashlytics.crashlytics().record(error: error)
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenue lors de la suppression de votre compte", completion: {})
              } else {
                AuthenticationLogout()
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()
              }
            }

        }, action2Title: "Non") {}
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
            FirestoreUtils.saveUser(uid: user.uid, name: displayName)
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

extension ParametersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nickNameTextField {
            emailTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text), let user = Auth.auth().currentUser else { return false }
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        let newName = textField == nickNameTextField ? updatedText : nickNameTextField.text
        let newEmail = textField == emailTextField ? updatedText : emailTextField.text
        
        
        self.changeValueContainer.isHidden = user.displayName == newName && user.email == newEmail
        
        return true
    }
}
