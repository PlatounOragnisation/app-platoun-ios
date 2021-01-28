//
//  InviteViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 06/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import MessageUI

protocol InviteViewControllerDelegate {
    func invitationClose(_ viewController: InviteViewController, animated: Bool)
    func showInvitation(_ invitation: InvitationType)
}

class InviteViewController: LightViewController {
    
    static func instance(productId: String, groupId: String, delegate: InviteViewControllerDelegate, text: String? = nil) -> InviteViewController {
        let vc = InviteViewController.instanceStoryboard()
        vc.productId = productId
        vc.groupId = groupId
        vc.delegate = delegate
        if text != nil {
            vc.customText = text!
        }
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    var delegate: InviteViewControllerDelegate!
    var productId: String!
    var groupId: String!
    
    var customText: String?
    
    @IBAction func actionClose(_ sender: Any) {
        self.delegate.invitationClose(self, animated: true)
    }
    
    @IBAction func actionMomunity(_ sender: Any) {
        self.delegate.showInvitation(.momunity(productId: self.productId, groupId: self.groupId))
    }
    
    @IBAction func actionWhatsapp(_ sender: Any) {
        self.delegate.showInvitation(
            .whatsapp(
                text: customText == nil ? InvitationConfig.whatsapp : "\(customText!)\n\(InvitationConfig.customText)"
            ))
    }
    
    @IBAction func actionMessenger(_ sender: Any) {
        self.delegate.showInvitation(.messenger(url: InvitationConfig.messenger))
    }
    
    @IBAction func actionEmail(_ sender: Any) {
        self.delegate?.showInvitation(
            .email(
                text: customText == nil ? InvitationConfig.email : "<p>\(customText!.replacingOccurrences(of: "\n", with: "</p><\\br><p>"))</p>\(InvitationConfig.customTextForEmail)"
            ))
    }
    
    @IBAction func actionSms(_ sender: Any) {
        self.delegate?.showInvitation(
            .sms(
                text: customText == nil ? InvitationConfig.sms : "\(customText!)\n\(InvitationConfig.customText)"
            ))
    }
    
}

extension InviteViewController: MomunityUsersViewControllerDelegate {
    func onClose(viewController: MomunityUsersViewController) {
        viewController.dismiss(animated: true)
        self.dismiss(animated: false)
    }
}
