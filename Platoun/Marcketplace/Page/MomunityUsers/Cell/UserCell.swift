//
//  UserCell.swift
//  Platoun
//
//  Created by Flavian Mary on 28/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol UserCellDelegate {
    func onClicInvite(user: PlatounUserCompact)
}

class UserCell: UITableViewCell {
    var user: PlatounUserCompact?
    var delegate: UserCellDelegate?
    
    @IBOutlet weak var userImageView: RoundedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inviteButton: BorderedButton!
    
    func setup(user: PlatounUserCompact, delegate: UserCellDelegate, isSelected: Bool) {
        self.user = user
        self.titleLabel.text = user.displayName ?? "No name"
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
        
        if let value = user.photoUrl, let url = URL(string: value) {
            self.userImageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
    }
    
    func cancel() {
        self.userImageView.sd_cancelCurrentImageLoad()
    }
    
    @IBAction func onClic(_ sender: Any) {
        guard let user = self.user else { return }
        self.delegate?.onClicInvite(user: user)
    }
}
