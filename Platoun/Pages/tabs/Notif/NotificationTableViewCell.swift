//
//  NotificationTableViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 19/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    static let identifier: String = "NotificationTableViewCell"

    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    
    var notification: PlatounNotification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(notification: PlatounNotification) {
        self.openLabel.text = "Ouvrir"
        self.notification = notification
        
        if self.setupInvitationNotif() {}
        else if self.setupStatusNotif() {}
        else {
            self.notificationTitleLabel.text = notification.title
            self.descriptionLabel.text = notification.message
            self.openLabel.isHidden = true
        }
    }
    
    private func setupStatusNotif() -> Bool {
        guard let notif = self.notification as? StatusPlatounNotification else { return false }
        
        switch notif.status {
        case .validated:
            self.notificationTitleLabel.text = "Félicitations! Ton groupe a été complété !"
            self.descriptionLabel.text = "Clique directement ici afin de pouvoir découvrir et utiliser ton code promotionnel."
        case .pending:
            self.notificationTitleLabel.text = notif.title
            self.descriptionLabel.text = notif.message
        case .failed:
            self.notificationTitleLabel.text = "Oh.. désolé, il semble que ton groupe n\'a pas pu être complété dans les temps."
            self.descriptionLabel.text = "Pas d\'inquiétude, tu peux encore en rejoindre un nouveau !"
        }

        self.openLabel.isHidden = notif.status != .validated
        
        return true
    }
    
    private func setupInvitationNotif() -> Bool {
        guard let notif = self.notification as? InvitPlatournNotification else { return false }
        
        self.notificationTitleLabel.text = "L'invitation expire bientôt."
        
        let message: String
        if let name = notif.senderName, !name.isEmpty {
            message = "\(notif.senderName!) t’invite à rejoindre son groupe."
        } else {
            message = "Une personne t’invite à rejoindre son groupe."
        }
        self.descriptionLabel.text = message
        self.openLabel.isHidden = false
        
        return true
    }

}
