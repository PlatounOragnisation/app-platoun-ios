//
//  InviteSuccessViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit


protocol InviteSuccessViewControllerDelegate {
    func backAfterSuccess(_ viewController: InviteSuccessViewController)
}

class InviteSuccessViewController: LightViewController {
    
    static func instance(delegate: InviteSuccessViewControllerDelegate) -> InviteSuccessViewController {
        let vc = InviteSuccessViewController.instanceStoryboard()
        vc.delegate = delegate
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    var delegate: InviteSuccessViewControllerDelegate!
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.delegate.backAfterSuccess(self)
    }
}
