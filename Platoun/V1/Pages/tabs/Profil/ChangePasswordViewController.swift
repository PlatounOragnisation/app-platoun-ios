//
//  ChangePasswordViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 31/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics

fileprivate extension UIView {
    func roundBar() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}

fileprivate extension UIButton {
    func customize() {
        let cornerRadius = self.frame.height/2

        let shadows = UIView()
        shadows.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        shadows.clipsToBounds = false
        self.insertSubview(shadows, at: 0)
        
        let emp = UIView()
        emp.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        emp.clipsToBounds = false
        emp.backgroundColor = ThemeColor.BackgroundPage
        emp.layer.cornerRadius = cornerRadius
        emp.layer.masksToBounds = true
        self.insertSubview(emp, at: 1)


        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: cornerRadius)

        let layer0 = CALayer()

        layer0.shadowPath = shadowPath0.cgPath
        
        layer0.shadowColor = ThemeColor.Black.withAlphaComponent(0.25).cgColor

        layer0.shadowOpacity = 0.8

        layer0.shadowRadius = 4

        layer0.shadowOffset = CGSize(width: 0, height: 1)

        layer0.bounds = shadows.bounds

        layer0.position = shadows.center

        shadows.layer.addSublayer(layer0)


        self.layer.cornerRadius = cornerRadius

        self.layer.borderWidth = 1

        self.layer.borderColor = ThemeColor.ValidateBorder.cgColor
        
        self.applyGradientWith(startColor: ThemeColor.BackgroundGradient1, endColor: ThemeColor.BackgroundGradient2)
    }
}

class ChangePasswordViewController: UIViewController {
    
    static func getInstance() -> ChangePasswordViewController {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        return vc
    }

    @IBOutlet weak var barIndicatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var oldButton: UIButton!
    @IBAction func oldButtonAction(_ sender: Any) {
        self.oldPasswordTextField.isSecureTextEntry = !self.oldPasswordTextField.isSecureTextEntry
        
        let image = self.oldPasswordTextField.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eyes_close") : #imageLiteral(resourceName: "ic_eyes_open")
        oldButton.setImage(image, for: .normal)
    }
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newButton: UIButton!
    @IBAction func newButtonAction(_ sender: Any) {
        self.newPasswordTextField.isSecureTextEntry = !self.newPasswordTextField.isSecureTextEntry
        
        let image = self.newPasswordTextField.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eyes_close") : #imageLiteral(resourceName: "ic_eyes_open")
        newButton.setImage(image, for: .normal)
    }
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func confirmButtonAction(_ sender: Any) {
        self.confirmPasswordTextField.isSecureTextEntry = !self.confirmPasswordTextField.isSecureTextEntry
        
        let image = self.confirmPasswordTextField.isSecureTextEntry ? #imageLiteral(resourceName: "ic_eyes_close") : #imageLiteral(resourceName: "ic_eyes_open")
        confirmButton.setImage(image, for: .normal)
    }
    @IBOutlet weak var valideButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        
        barIndicatorView.roundBar()
        titleLabel.text = "Changement de mot de passe"
        oldPasswordTextField.placeholder = "Ancien mot de passe"
        forgotPasswordButton.setTitle("Mot de passe oublié ?", for: .normal)
        newPasswordTextField.placeholder = "Nouveau mot de passe"
        confirmPasswordTextField.placeholder = "Confirmer le mot de passe"
        valideButton.setTitle("Valider", for: .normal)
        
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        self.updatePreferredContentSize(with: self.traitCollection)
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(barIndicatorSwiped))
        gesture.direction = .down
        self.barIndicatorView.addGestureRecognizer(gesture)
        
        valideButton.customize()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(saveNewPasswordAction))
        self.valideButton.addGestureRecognizer(tap)
    }
    
    @objc func barIndicatorSwiped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func forgotPassordAction(_ sender: Any) {
        guard let auth = try? Auth.auth().currentUser?.getAuthentication() else { return }
        
        auth.resetPassword(from: self, callBack: { result in
            switch result {
            case .success():
                UIKitUtils.showAlert(in: self, message: "Le mail de réinitialisation de mot de passe à bien été envoyé.") {}
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenue : \(error.localizedDescription)") {}
            }
        })
    }
    
    @IBAction func saveNewPasswordAction(_ sender: Any) {
        let olPassword = oldPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !newPassword.isEmpty && newPassword == confirmPassword else {
            
            if newPassword.isEmpty {
                UIKitUtils.showAlert(in: self, message: "Le nouveau mot de passe ne peut pas être vide.") {}
            } else {
                UIKitUtils.showAlert(in: self, message: "Les deux nouveaux mot de passe ne sont pas identiques") {}
            }
            return
        }
        guard let auth = try? Auth.auth().currentUser?.getAuthentication() else { return }
        auth.changePassword(from: self, olPassword: olPassword, newPassord: newPassword, callBack: { result in
            switch result {
            case .success():
                UIKitUtils.showAlert(in: self, message: "Votre mot de passe à bien été changé.") {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                if (error as NSError).code == AuthErrorCode.wrongPassword.rawValue {
                    UIKitUtils.showAlert(in: self, message: "Votre mot de passe est incorrect") {}
                } else if (error as NSError).code == AuthErrorCode.weakPassword.rawValue {
                    UIKitUtils.showAlert(in: self, message: "Votre mot de passe doit faire 6 caractères minimum.") {}
                } else {
                    Crashlytics.crashlytics().record(error: error)
                    UIKitUtils.showAlert(in: self, message: "Une erreur est survenue : \(error.localizedDescription)") {}
                }
            }
        })
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updatePreferredContentSize(with: newCollection)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(
            width: self.view.bounds.size.width,
            height: traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact ? 334 : 520)
    }
    
    func updatePreferredContentSize(with keyboardHeight: CGFloat) {
        let height = (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact ? 334 : 520) + keyboardHeight
        self.preferredContentSize = CGSize(
            width: self.view.bounds.size.width,
            height: min(height, UIScreen.main.bounds.height - 40)
        )
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
            if let userInfo = notification.userInfo {
                let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let endFrameY = endFrame?.origin.y ?? 0
                let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                
                let height: CGFloat
                if endFrameY >= UIScreen.main.bounds.size.height {
                    height = 0.0
                } else {
                    height = (endFrame?.size.height ?? 0.0) - ( self.tabBarController?.tabBar.frame.size.height ?? self.view.safeAreaInsets.bottom)
                }
                self.bottomConstraint.constant = -height
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: {
                                self.updatePreferredContentSize(with: height)
                                self.view.layoutIfNeeded()
                               },
                               completion: nil
                )
            }
        }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPasswordTextField {
            self.newPasswordTextField.becomeFirstResponder()
        } else if textField == newPasswordTextField {
            self.confirmPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
