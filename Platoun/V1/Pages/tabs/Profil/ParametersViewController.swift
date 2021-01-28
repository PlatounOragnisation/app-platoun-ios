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
        case .account:
            self.backgroundColor = ThemeColor.BackgroundButton
            self.setTitleColor(ThemeColor.White, for: .normal)
        case .password:
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
    
    @IBOutlet weak var profilImage: AddImageView!
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
    @IBOutlet weak var changeValuesNotifContainer: UIView!
    @IBOutlet weak var changeValueLoader: UIActivityIndicatorView!
    @IBOutlet weak var changeValuesNotifButton: UIButton!
    @IBOutlet weak var removeAccountButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var platounUser: PlatounUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        
        self.navigationItem.title = "Paramètres"
        self.profilImage.delegate = self
        self.changeValueLoader.isHidden = true
        self.changeValuesButton.setTitle("Valider le changement", for: .normal)
        self.changeValuesNotifButton.setTitle("Valider le changement", for: .normal)
        self.changePasswordButton.setTitle("Modifier Mot de passe", for: .normal)
        self.logoutButton.setTitle("Se déconnecter ", for: .normal)
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
        self.changeValuesNotifButton.round(type: .value)
        self.changeValuesNotifContainer.isHidden = true
        
        self.nickNameTextField.delegate = self
        self.emailTextField.delegate = self
        
        guard let user = Auth.auth().currentUser else { return }
        
        changePasswordContainer.isHidden = !user.isPassword
        self.changePasswordButton.round(type: .password)
        self.logoutButton.round(type: .password)
        
        self.removeAccountButton.round(type: .account)
        
        nickNameTextField.placeholder = "Prénom"
        emailTextField.placeholder = "Adresse email"
        
        
        nickNameTextField.text = user.displayName ?? ""
        emailTextField.text = user.email ?? ""
        
        self.profilImage.updateWith(user: user)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reload()
    }
    
    func reload() {
        guard let user = Auth.auth().currentUser else { self.logOut(); return }
        FirestoreUtils.Users.getUser(uid: user.uid) { result in
            switch result {
            case .success(let platounUser):
                self.platounUser = platounUser
                self.notifCategory1Switch.setOn(on: platounUser.groupNotification, animated: false)
                self.notifCategory2Switch.setOn(on: platounUser.trendsNotification, animated: false)
                self.notifCategory3Switch.setOn(on: platounUser.newsNotification, animated: false)
                self.checkValueNotifChange()
            case .failure:
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenue merci de vous reconnecter.") {
                    self.logOut()
                }
            }
        }
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
        let value = !self.notifCategory1Switch.isOn
        self.notifCategory1Switch.setOn(on: value, animated: true)
        self.checkValueNotifChange()
    }
    
    @objc func clickCategory2Container() {
        let value = !self.notifCategory2Switch.isOn
        self.notifCategory2Switch.setOn(on: value, animated: true)
        self.checkValueNotifChange()
    }
    
    @objc func clickCategory3Container() {
        let value = !self.notifCategory3Switch.isOn
        self.notifCategory3Switch.setOn(on: value, animated: true)
        self.checkValueNotifChange()
    }
    
    func checkValueNotifChange() {
        guard let user = platounUser else { self.logOut(); return }
        self.changeValuesNotifContainer.isHidden =
            notifCategory1Switch.isOn == user.groupNotification &&
            notifCategory2Switch.isOn == user.trendsNotification &&
            notifCategory3Switch.isOn == user.newsNotification
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        let vc = ChangePasswordViewController.getInstance()
        
        let presentationController = CustomPresentationController(presentedViewController: vc, presenting: self)
        
        vc.transitioningDelegate = presentationController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        self.logOut()
    }
    
    @IBAction func changeValuesNotifAction(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { self.logOut(); return }
        let groupNotif = self.notifCategory1Switch.isOn
        let trendsNotif = self.notifCategory2Switch.isOn
        let newsNotif = self.notifCategory3Switch.isOn
        
        FirestoreUtils.Users.saveUser(uid: user.uid, groupNotification: groupNotif, trendsNotification: trendsNotif, newsNotification: newsNotif)
        self.reload()
    }
    
    @IBAction func changeValuesAction(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        guard let utils = UserUtils(user: user) else { return }
        self.changeValuesButton.isHidden = true
        self.changeValueLoader.startAnimating()
        
        var modifications: [UserUtils.ModificationType] = []
        
        if let image = self.profilImage.image, self.profilImage.modified {
            modifications.append(.photo(image))
        }
        
        if let displayName = self.nickNameTextField.text, user.displayName != displayName {
            modifications.append(.name(displayName))
        }
        
        if let email = self.emailTextField.text, user.email != email {
            modifications.append(.email(email))
            
            utils.authentication.reAuth(from: self) { result in
                switch result {
                case .success:
                    self.start(utils: utils, user: user, modifications: modifications)
                case .failure(let error):
                    Crashlytics.crashlytics().record(error: error)
                    self.changeValuesButton.isHidden = false
                    self.changeValueLoader.stopAnimating()
                    UIKitUtils.showAlert(in: self, message: "Une erreur est survenue lors de votre reconnexion. Merci de vous reconnecter.") {
                        self.logoutButtonAction("")
                    }
                }
            }
            return
        }
        
        
        self.start(utils: utils, user: user, modifications: modifications)
    }
    
    private func start(utils: UserUtils, user: User, modifications: [UserUtils.ModificationType]) {
        utils.start(modifications: modifications, from: self) { (success, message) in
            DispatchQueue.main.async {
                if success {
                    UIKitUtils.showAlert(in: self, message: message) {
                        guard let user = Auth.auth().currentUser else { return }
                        self.nickNameTextField.text = user.displayName ?? ""
                        self.emailTextField.text = user.email ?? ""
                        self.profilImage.updateWith(user: user)
                        self.changeValueContainer.isHidden = true
                        self.nickNameTextField.resignFirstResponder()
                        self.emailTextField.resignFirstResponder()
                    }
                } else {
                    self.nickNameTextField.resignFirstResponder()
                    self.emailTextField.resignFirstResponder()
                    UIKitUtils.showAlert(in: self, message: message) {}
                }
                user.reload { (error) in
                    self.changeValuesButton.isHidden = false
                    self.changeValueLoader.stopAnimating()
                    if let error = error {
                        Crashlytics.crashlytics().record(error: error)
                    }
                }
            }
        }
    }
    
    func logOut() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        let tab = appDelegate?.window?.rootViewController as? TabViewController
//        tab?.stopBind()
        
        AuthenticationLogout()
        appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()
    }
    
    @IBAction func removeAccountAction(_ sender: Any) {
        guard let authentication = try? Auth.auth().currentUser?.getAuthentication() else { return }
        UIKitUtils.showAlert(in: self, message: "Êtes-vous sur de vouloir supprimer votre compte ?", action1Title: "Oui", completionOK: {
            
            
            authentication.reAuth(from: self) { authResult in
                switch authResult {
                case .success:
                    let user = Auth.auth().currentUser
                    user?.delete { error in
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                            UIKitUtils.showAlert(in: self, message: "Une erreur est survenue lors de la suppression de votre compte", completion: {})
                        } else {
                            self.logOut()
                        }
                    }
                case .failure(let error):
                    UIKitUtils.showAlert(in: self, message: "Un problème est survenue merci de vous reconnecter:\n\(error)") {
                        self.logOut()
                    }
                }
            }
        }, action2Title: "Non") {}
    }
}

extension ParametersViewController: AddImageViewDelegate {
    func imageWasChanged() {
        guard let user = Auth.auth().currentUser else { return }
        let newName = nickNameTextField.text
        let newEmail = emailTextField.text
        
        self.changeValueContainer.isHidden = user.displayName == newName && user.email == newEmail && !profilImage.modified
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
        
        
        self.changeValueContainer.isHidden = user.displayName == newName && user.email == newEmail && !profilImage.modified
        
        return true
    }
}
