//
//  CreateGroupViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 23/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateGroupViewController: LightViewController {
    
    static func instance(product: ProductSummary, success: @escaping (String, String, String)->Void) -> CreateGroupViewController {
        let viewController = CreateGroupViewController.instanceStoryboard()
        viewController.product = product
        viewController.success = success
        return viewController
    }
    
    private var product: ProductSummary!
    private var success: ((String, String, String)->Void)!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var members3Button: UIButton!
    @IBOutlet weak var members5Button: UIButton!
    @IBOutlet weak var validateGroupButton: UIButton!
    @IBOutlet weak var publicGroupSwitch: UISwitch!
    @IBOutlet weak var titlePinLabel: UILabel!
    @IBOutlet weak var pinCodeLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var countChar: UILabel!
    @IBOutlet weak var promoCodeLabel: UILabel!
    
    @IBAction func actionMembers3(_ sender: Any) { self.members3IsSelected = true }
    @IBAction func actionMembers5(_ sender: Any) { self.members3IsSelected = false }
    @IBOutlet weak var user1: ImageShadow!
    @IBOutlet weak var user2: ImageShadow!
    @IBOutlet weak var user3: ImageShadow!
    @IBOutlet weak var user4: ImageShadow!
    @IBOutlet weak var user5: ImageShadow!
    @IBOutlet weak var containerUser4_5: UIStackView!
    
    var interactor = CreateGroupInteractor()
    
    var members3IsSelected = true {
        didSet {
            let selected = UIImage(named: "ic-check-on")
            let notSelected = UIImage(named: "ic-check-off")
            
            let prct = self.product.percentage + (self.members3IsSelected ? 0 : 5)
            self.promoCodeLabel.text = "-\(prct)%"
            
            DispatchQueue.main.async {
                self.members3Button.setImage(self.members3IsSelected ? selected : notSelected, for: .normal)
                self.members5Button.setImage(self.members3IsSelected ? notSelected : selected, for: .normal)
                
                self.containerUser4_5.isHidden = self.members3IsSelected
            }
        }
    }
    
    var pinCode: String = ""
        
    func getPinCode(_ pin: String) {
        self.pinCode = pin
        
        let text: String
        let title: String
        if self.pinCode.count == 0 {
            text = ""
            title = "Create a Private Group".localise()
        } else {
            text = "Pin".localise() + " : \(Array(pin).map { "\($0)" } .joined(separator: " "))"
            title = "Back to public group".localise()
        }
        self.publicGroupSwitch.isOn = self.pinCode.count != 0
        self.titlePinLabel.text = title
        self.pinCodeLabel.text = text
    }
    
    @IBAction func actionPublicGroup(_ sender: Any) {
        if !self.publicGroupSwitch.isOn {
            self.getPinCode("")
        } else {
            let vc = PinCodeViewController.instance(
                correctPin: nil,
                success: { pin in
                    self.getPinCode(pin)
                },
                error: { _ in
                    self.publicGroupSwitch.isOn = true
                    self.getPinCode(self.pinCode)
                }
            )
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    var isClicCreate = false
    
    @IBAction func actionValidate(_ sender: Any) {
        if isClicCreate { return }
        isClicCreate = true
        let code = self.pinCode.count == 4 ? self.pinCode : ""
        let userCount = self.members3IsSelected ? 3 : 5
        self.interactor.createGroup(code: code, userCount: userCount, productId: product.id) { (groupId, message) in
            self.isClicCreate = false
            if let id = groupId {
                self.dismiss(animated: false, completion: nil)
                self.success(self.product.id, id, self.textView.text)
            } else if let text = message {
                let alert = UIAlertController(title: "Oups !".localise(), message: text, preferredStyle: .alert)
                
                let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
                action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
                
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        validateGroupButton.setTitle("Validate".localise(), for: .normal)
        
        guard let user = Auth.auth().currentUser else { return }
        self.hideKeyboardWhenTappedAround()
        self.textView.addDoneButton(title: "Done".localise(), target: self, selector: #selector(okPressed))
        self.containerUser4_5.isHidden = self.members3IsSelected
        
        self.user2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicUser)))
        self.user3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicUser)))
        self.user4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicUser)))
        self.user5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicUser)))
        
        textView.text = "Hey, the Momunity app, a super app for moms like us, has a great new concept store! If we team up, we'll get special deals on the best mom & baby products. Sign up here and let's shop together!".localise()
        countChar.text = "\(textView.text.count) / 300"
        textView.delegate = self
        
        self.imageView.setImage(with: URL(string: self.product.pictureLink), placeholder: nil, options: .progressiveLoad)
        self.getPinCode("")
        let prct = self.product.percentage + (self.members3IsSelected ? 0 : 5)
        self.promoCodeLabel.text = "-\(prct)%"
        
        if let value = user.photoURL {
            self.user1.imageView.setImage(with: value, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.user1.imageContent = #imageLiteral(resourceName: "ic_social_default_profil")
        }
    }
    
    @objc func onClicUser() {
        let alert = UIAlertController(title: "Oups !".localise(), message: "", preferredStyle: .alert)
        
        let myAttribute: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let myAttribute2: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#038091")!
        ]
        
        let value1 = NSMutableAttributedString(string: "You need to".localise() + " ", attributes: myAttribute)
        let value2 = NSMutableAttributedString(string: "validate".localise(), attributes: myAttribute2)
        let value3 = NSMutableAttributedString(string: " "+"your group before inviting some friends 🙂".localise(), attributes: myAttribute)
        
        let value = value1
        
        value.append(value2)
        value.append(value3)
        
        alert.setValue(value, forKey: "attributedMessage")
        
        let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
        action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)        
    }
    
    @objc func okPressed() {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = 34
        view.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
extension CreateGroupViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.countChar.text = "\(textView.text.count) / 300"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.countChar.text = "\(textView.text.count) / 300"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length > 0 {
            guard textView.text.count + text.count > 300 else { return true }
            return range.length >= text.count
        }
        return textView.text.count + text.count <= 300
    }
}

extension CreateGroupViewController: InviteViewControllerDelegate {
    func invitationClose(_ viewController: InviteViewController, animated: Bool) {
        viewController.dismiss(animated: animated)
    }
    
    func showInvitation(_ invitation: InvitationType) {
        Invitation().show(in: self, type: invitation)
    }
}
