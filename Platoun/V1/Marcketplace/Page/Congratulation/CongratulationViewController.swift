//
//  CongratulationViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 06/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class CongratulationViewController: LightViewController {
    static func instance(productId: String, groupId: String, text: String?, finish: @escaping ()->Void) -> CongratulationViewController {
        let vc = CongratulationViewController.instanceStoryboard()
        vc.productId = productId
        vc.groupId = groupId
        vc.text = text
        vc.finish = finish
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
        
    var productId: String!
    var groupId: String!
    var text: String?
    @IBOutlet weak var contentLabel: UILabel!
    
    var finish: (()->Void)!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentLabel.attributedText = NSMutableAttributedString()
            .normal("You are part of the group!\nLet's invite a friend to increase the chance of\nsuccess!".localise(), fontSize: 14)
    }
    
    @IBAction func actionYes(_ sender: Any) {
        let vc = InviteViewController.instance(productId: self.productId, groupId: self.groupId, delegate: self, text: self.text)
        
        self.present(vc, animated: true)
    }
    
    
    @IBAction func actionNo(_ sender: Any) {
        self.dismiss(animated: true) {
            self.finish()
        }
    }
    
}
extension CongratulationViewController: InviteViewControllerDelegate {
    func invitationClose(_ viewController: InviteViewController, animated: Bool) {
        viewController.dismiss(animated: true) {
            self.dismiss(animated: true) {
                self.finish()
            }
        }
//        viewController.superDismiss(animated: true)
    }
    
    func showInvitation(_ invitation: InvitationType) {
        Invitation().show(in: self, type: invitation)
    }
}
