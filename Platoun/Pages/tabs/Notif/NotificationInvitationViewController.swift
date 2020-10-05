//
//  NotificationInvitationViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 11/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import FirebaseAuth

class NotificationInvitationViewController: LightViewController {
    static func instance(notification: InvitPlatournNotification) -> NotificationInvitationViewController {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotificationInvitationViewController") as! NotificationInvitationViewController
        vc.notification = notification
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    var notification: InvitPlatournNotification!
    
    private var timer: Timer?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: RoundedView!
    @IBOutlet weak var promocodeLabel: RotatedLabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var soloPriceLabel: UILabel!
    @IBOutlet weak var groupPriceLabel: UILabel!
    @IBOutlet weak var dealEndLabel: UILabel!
    @IBOutlet weak var placesLeftLabel: UILabel!
    @IBOutlet weak var stack1_3: UIStackView!
    @IBOutlet weak var stack4_5: UIStackView!
    @IBOutlet weak var user1ImageView: ImageShadow!
    @IBOutlet weak var user1Label: UILabel!
    @IBOutlet weak var offerYouLabel: UILabel!
    @IBOutlet weak var offerJoinLabel: UILabel!
    @IBOutlet weak var user2ImageView: ImageShadow!
    @IBOutlet weak var user3ImageView: ImageShadow!
    @IBOutlet weak var user4ImageView: ImageShadow!
    @IBOutlet weak var user5ImageView: ImageShadow!
    
    @IBOutlet weak var loaderButton: UIView!
    @IBOutlet weak var yesButton: BorderedButton!
    @IBOutlet weak var noButton: BorderedButton!
    
    
    var webNotification: WebNotification? {
        didSet {
            self.updateView()
        }
    }
    
    var users: [String: PlatounUser] = [:] {
        didSet {
            self.updateUsersImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loaderButton.isHidden = true
        self.yesButton.isHidden = false
        self.noButton.isHidden = false
        self.loadingView.isHidden = false
        self.contentView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = Auth.auth().currentUser else { return }
        
        offerJoinLabel.attributedText = NSMutableAttributedString()
            .normal("Do you want to".localise() + " ", fontSize: 14)
            .bold("join".localise(), fontSize: 14, color: UIColor(hex: "#038091"))
            .normal(" " + "the team ?".localise(), fontSize: 14)
        
        Interactor.shared.showNotif(userId: user.uid, sendUserId: self.notification.senderUserId, groupId: self.notification.groupId) { value in
            guard let notif = value else {
                UIKitUtils.showAlert(in: self, message: "Mince, nous n'arrive pas à retrouver le groupe. Il doit être terminé.") {
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            
            FirestoreUtils.Users.getUsers(ids: notif.users.map { $0.userId }) { result in
                switch result {
                case .success(let res):
                    self.users = res
                case .failure(let error):
                    Crashlytics.crashlytics().record(error: error)
                }
            }
            
            self.webNotification = value
            self.startTimer()
        }
    }
    
    func setUser(image: ImageShadow, label: UILabel?, user: WebUser?) {
        if let user = user {
            if let value = users[user.userId]?.photoUrl, let url = URL(string: value) {
                image.imageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
            } else {
                image.imageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
            }
            label?.text = users[user.userId]?.displayName ?? "No name"
            if label != nil {
                offerYouLabel.attributedText = NSMutableAttributedString()
                    .bold(label?.text ?? "", fontSize: 14)
                    .normal(" " + "offers you to join her group deal.".localise(), fontSize: 14)
            }
        } else {
            image.imageView.image = UIImage(named: "ic-no-user")
        }
    }
    
    func updateUsersImage() {
        guard let webNotification = self.webNotification else { return }
        
        setUser(image: user1ImageView, label: user1Label, user: webNotification.users.getOrNil(0))
        setUser(image: user2ImageView, label: nil, user: webNotification.users.getOrNil(1))
        setUser(image: user3ImageView, label: nil, user: webNotification.users.getOrNil(2))
        setUser(image: user4ImageView, label: nil, user: webNotification.users.getOrNil(3))
        setUser(image: user5ImageView, label: nil, user: webNotification.users.getOrNil(4))
    }
    
    func updateView() {
        self.contentView.isHidden = webNotification == nil
        self.loadingView.isHidden = !self.contentView.isHidden
        
        guard let webNotification = self.webNotification else { return }
        
        productNameLabel.text = webNotification.productName
        brandNameLabel.text = webNotification.productBrand
        productImageView.downloaded(from: webNotification.productPicture)
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(webNotification.soloPrice)€")
        attributeString.addAttribute(.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        self.soloPriceLabel.attributedText = attributeString
        groupPriceLabel.text = "\(webNotification.groupPrice)€"
        let count = webNotification.maxUsers - webNotification.users.count
        
        let placesLeftText: String
        if count > 1 {
            placesLeftText = "only %d places left"
        } else {
            placesLeftText = "only %d place left"
        }
        
        placesLeftLabel.text = placesLeftText.localise(count)
        stack4_5.isHidden = webNotification.maxUsers == 3
    }
    
    @objc func updateDealEnd() -> Int {
        guard let webNotification = self.webNotification else { return  0 }
        let date = Date()
        let count = (webNotification.maxUsers == 5 ? 72 : 48) * 60 * 60
        let endDate = webNotification.dateAdded.addingTimeInterval(TimeInterval(count))
        let countSecond = Int(endDate.timeIntervalSince(date))
        if(countSecond >= 0) {
            let hours: Int = (countSecond / (60 * 60))
            let min: Int = (countSecond / 60) - ( 60 * hours )
            
            dealEndLabel.text = "Deal ends in".localise() + " \(hours)h \(min)min"
        } else {
            dealEndLabel.text = "Deal ends finish".localise()
        }
        return countSecond
    }
    
    func startTimer() {
        if timer == nil {
            _ = self.updateDealEnd()
            timer = Timer(timeInterval: 60.0, repeats: true) { _ in
                let countSecond = self.updateDealEnd()
                if countSecond <= 0 {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    @IBAction func actionYes(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        self.yesButton.isHidden = true
        self.loaderButton.isHidden = false
        Interactor.shared.respondNotif(userId: user.uid, userInviterId: self.notification.senderUserId, groupId: self.notification.groupId, accepted: true) { result in
            
            switch result {
            case .success(let respond):
                FirestoreUtils.Notifications.deleteNotification(userId: user.uid, notifId: self.notification.id)
                
                if respond.isValidated, let promocode = respond.promoCode, let link = respond.link {
                    let parent = self.presentingViewController
                    self.dismiss(animated: true) {
                        let vc = SuccessViewController.instance(promocode: promocode, link: link)
                        parent?.present(vc, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Vous avez été ajouté à ce groupe.", message: nil, preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    })
                    action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
                    
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                
                var message = "Mince, un problème est survenue"
                
                if case .platounError(let webError) = (error as? CustomError) {
                    message += " : \(webError.error)"
                }
                
                UIKitUtils.showAlert(in: self, message: message) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            self.yesButton.isHidden = false
            self.loaderButton.isHidden = true
        }
    }
    
    @IBAction func actionNo(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        self.noButton.isHidden = true
        self.loaderButton.isHidden = false
        Interactor.shared.respondNotif(userId: user.uid, userInviterId: self.notification.senderUserId, groupId: self.notification.groupId, accepted: false) { result in
            
            switch result {
            case .success(_):
                FirestoreUtils.Notifications.deleteNotification(userId: user.uid, notifId: self.notification.id)
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                
                UIKitUtils.showAlert(in: self, message: "Mince, un problème est survenue") {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            self.noButton.isHidden = false
            self.loaderButton.isHidden = true
        }
    }
    
    @IBAction func actionLater(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
