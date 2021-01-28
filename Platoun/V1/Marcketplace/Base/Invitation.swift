//
//  Invitation.swift
//  Platoun
//
//  Created by Flavian Mary on 08/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import MessageUI

enum InvitationType {
    case momunity(productId: String, groupId: String)
    case whatsapp(text: String)
    case messenger(url: String)
    case email(text: String)
    case sms(text: String)
}

class Invitation: NSObject {
    func show(in vc: UIViewController, type: InvitationType) {
        switch type {
        case .momunity(let productId, let groupId):
            self.byMomunity(in: vc, productId: productId, groupId: groupId)
        case .whatsapp(let text):
            self.byWhatsApp(in: vc, text: text)
        case .messenger(let url):
            self.byMessenger(in: vc, urlString: url)
        case .email(let text):
            self.byEmail(in: vc, text: text)
        case .sms(let text):
            self.bySms(in: vc, text: text)
        }
    }
    
    private func byMomunity(in vc: UIViewController, productId: String,  groupId: String) {
        let controller = MomunityUsersViewController.instance(productId: productId, groupId: groupId, delegate: self)
        
        vc.presentedViewController?.dismiss(animated: false)
        vc.present(controller, animated: true, completion: nil)
    }
    
    private func byWhatsApp(in vc: UIViewController, text: String) {
        let urlStringEncoded = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url  = URL(string: "whatsapp://send?text=\(urlStringEncoded!)")!
        
        guard UIApplication.shared.canOpenURL(url) else { return }
        
        
        vc.presentedViewController?.dismiss(animated: false)
        UIApplication.shared.open(url, options: [:]) { (success) in
            if success {
                print("WhatsApp accessed successfully")
            } else {
                print("Error accessing WhatsApp")
            }
        }
    }
    
    private func byMessenger(in vc: UIViewController, urlString: String) {
        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url  = URL(string: "fb-messenger://share?link=\(urlStringEncoded!)")!
        
        guard UIApplication.shared.canOpenURL(url) else { return }
        
        vc.presentedViewController?.dismiss(animated: false)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if success {
                    print("Messenger accessed successfully")
                } else {
                    print("Error accessing Messenger")
                }
            }
        }
    }
    
    private func bySms(in vc: UIViewController, text: String) {
        guard MFMessageComposeViewController.canSendText() else { return }

        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = vc
        
        // Configure the fields of the interface.
        composeVC.recipients = []
        composeVC.body = text
        
                
        vc.presentedViewController?.dismiss(animated: false)
        vc.present(composeVC, animated: true, completion: nil)
    }
    
    private func byEmail(in vc: UIViewController, text: String) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = vc
        mail.setToRecipients([])
        
        mail.setMessageBody(text, isHTML: true)
        
        vc.presentedViewController?.dismiss(animated: false)
        vc.present(mail, animated: true, completion: nil)
    }
}

extension Invitation: MomunityUsersViewControllerDelegate {
    func onClose(viewController: MomunityUsersViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail accessed cancel")
        case .sent:
            print("Mail accessed successfully")
        case .failed:
            print("Mail accessed error")
        case .saved:
            print("Mail accessed saved")
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}


extension UIViewController: MFMessageComposeViewControllerDelegate {
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("SMS accessed cancel")
        case .sent:
            print("SMS accessed successfully")
        case .failed:
            print("SMS accessed error")
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
