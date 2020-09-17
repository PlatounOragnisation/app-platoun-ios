//
//  UserCell.swift
//  Platoun
//
//  Created by Flavian Mary on 28/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol UserCellDelegate {
    func onClicInvite(user: UserMomunity)
}

class UserCell: UITableViewCell {
    var user: UserMomunity?
    var delegate: UserCellDelegate?
    
    @IBOutlet weak var userImageView: RoundedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inviteButton: BorderedButton!
    
    func setup(user: UserMomunity, delegate: UserCellDelegate, isSelected: Bool) {
        self.user = user
        self.titleLabel.text = user.firstName
        self.delegate = delegate
        
        if isSelected {
            inviteButton.setTitle("undo".localise(), for: .normal)
            inviteButton.borderColor = UIColor(hex: "#00D5CA")!
            inviteButton.backgroundColor = UIColor(hex: "#E9E9E9")!
            inviteButton.setTitleColor(UIColor(hex: "#222222")!, for: .normal)
        } else {
            inviteButton.setTitle("invite".localise(), for: .normal)
            inviteButton.borderColor = UIColor(hex: "#FFFFFF")!
            inviteButton.backgroundColor = UIColor(hex: "#038091")!
            inviteButton.setTitleColor(UIColor(hex: "#FFFFFF")!, for: .normal)
        }
        
        
        
        self.userImageView.downloaded(from: user.picture)
    }
    
    
    @IBAction func onClic(_ sender: Any) {
        guard let user = self.user else { return }
        self.delegate?.onClicInvite(user: user)
    }
}
