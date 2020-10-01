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
        self.notificationTitleLabel.text = notification.title
        self.descriptionLabel.text = notification.message
        
        if let statusNotification = notification as? StatusPlatounNotification {
            self.openLabel.isHidden = statusNotification.status != .validated
        } else if notification is InvitPlatournNotification {
            self.openLabel.isHidden = false
        } else {
            self.openLabel.isHidden = true
        }
    }

}
