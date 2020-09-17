//
//  NotificationInvitationViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 11/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class NotificationInvitationViewController: LightViewController {
    static func instance(sendUserId: String, currentUserId: String, groupId: String) -> NotificationInvitationViewController {
        let vc = NotificationInvitationViewController.instanceStoryboard()
        vc.currentUserId = currentUserId
        vc.sendUserId = sendUserId
        vc.groupId = groupId
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    var currentUserId: String!
    var sendUserId: String!
    var groupId: String!
    
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
    
    
    
    var webNotification: WebNotification? {
        didSet {
            self.updateView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        offerJoinLabel.attributedText = NSMutableAttributedString()
            .normal("Do you want to".localise() + " ", fontSize: 14)
            .bold("join".localise(), fontSize: 14, color: UIColor(hex: "#038091"))
            .normal(" " + "the team ?".localise(), fontSize: 14)
        
        Interactor.shared.showNotif(userId: currentUserId, sendUserId: sendUserId, groupId: groupId) { value in
            guard let notif = value else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.webNotification = value
            self.startTimer()
        }
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
        
        if let user = webNotification.users.getOrNil(0) {
            user1ImageView.downloaded(from: user.profilePictureLink.trimed ?? HttpServices.defaultUserImg)
            user1Label.text = user.name
            
            offerYouLabel.attributedText = NSMutableAttributedString()
                .bold(user.name ?? "", fontSize: 14)
                .normal(" " + "offers you to join her group deal.".localise(), fontSize: 14)
        }
        if let user = webNotification.users.getOrNil(1) {
            user2ImageView.downloaded(from: user.profilePictureLink.trimed ?? HttpServices.defaultUserImg)
        }
        if let user = webNotification.users.getOrNil(2) {
            user3ImageView.downloaded(from: user.profilePictureLink.trimed ?? HttpServices.defaultUserImg)
        }
        if let user = webNotification.users.getOrNil(3) {
            user4ImageView.downloaded(from: user.profilePictureLink.trimed ?? HttpServices.defaultUserImg)
        }
        if let user = webNotification.users.getOrNil(4) {
            user5ImageView.downloaded(from: user.profilePictureLink.trimed ?? HttpServices.defaultUserImg)
        }
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
        Interactor.shared.respondNotif(userId: currentUserId, userInviterId: sendUserId, groupId: groupId, accepted: true) { (res, groupIsComplet, p, bl) in
            if res {
                
                if groupIsComplet, let promocode = p, let buyLink = bl {
                    let parent = self.presentingViewController
                    self.dismiss(animated: true) {
                        let vc = SuccessViewController.instance(promocode: promocode, link: buyLink)
                        parent?.present(vc, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "You've been added to this group.".localise(), message: nil, preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "OK".localise(), style: .default, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    })
                    action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
                    
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
            } else {
                
            }
        }
    }
    
    @IBAction func actionNo(_ sender: Any) {
        Interactor.shared.respondNotif(userId: currentUserId, userInviterId: sendUserId, groupId: groupId, accepted: false) { (res, groupIsComplet, _, _) in
            if res {
                self.dismiss(animated: true, completion: nil)
            } else {
                
            }
        }
    }
    
    @IBAction func actionLater(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
