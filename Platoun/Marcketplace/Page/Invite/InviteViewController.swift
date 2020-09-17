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
            vc.text = text!
        }
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    var delegate: InviteViewControllerDelegate!
    var productId: String!
    var groupId: String!
    
    
    var text: String = "Hey, the Momunity app, a super app for moms like us, has a great new concept store! If we team up, we'll get special deals on the best mom & baby products. Sign up here and let's shop together!".localise()
    
    let moreText = "\n" + "Just download the app for free here :".localise() + "\n" + "App Store".localise() + ": http://bit.ly/momunity \n" + "Google Play".localise() + ": https://play.google.com/store/apps/details?id=com.momunity"
    
    var finalText: String {
        get {
            return text+moreText
        }
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.delegate.invitationClose(self, animated: true)
    }
    
    @IBAction func actionMomunity(_ sender: Any) {
        self.delegate.showInvitation(.momunity(productId: self.productId, groupId: self.groupId))
    }
    
    @IBAction func actionWhatsapp(_ sender: Any) {
        self.delegate.showInvitation(.whatsapp(text: finalText))
    }
    
    @IBAction func actionMessenger(_ sender: Any) {
        self.delegate.showInvitation(.messenger(url: "http://bit.ly/momunity"))
    }
    
    @IBAction func actionEmail(_ sender: Any) {
        let replacing = text.replacingOccurrences(of: "\n", with: "</p><\\br><p>")
        
        let htmlText = "<p>\(replacing)</p><p>" + "Just download the app for free here :".localise() + "</p><p><a href=\"http://bit.ly/momunity\">" + "App Store".localise() + "</a></p><p><a href=\"https://play.google.com/store/apps/details?id=com.momunity\">" + "Google Play".localise() + "</a></p>"
        
        self.delegate?.showInvitation(.email(text: htmlText))
    }
    
    @IBAction func actionSms(_ sender: Any) {
        self.delegate?.showInvitation(.sms(text: finalText))
    }
    
}

extension InviteViewController: MomunityUsersViewControllerDelegate {
    func onClose(viewController: MomunityUsersViewController) {
        viewController.dismiss(animated: true)
        self.dismiss(animated: false)
    }
}
