//
//  DrawerViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 23/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol DrawerViewControllerDelegate {
    func showPromoCode()
    func showGroupStatus()
    func showProductsLiked()
    func showSupport()
}

class DrawerViewController: LightViewController {
        
    static func instance() -> DrawerViewController {
        let vc = DrawerViewController.instanceStoryboard()
        return vc
    }
    
    var delegate: DrawerViewControllerDelegate?
    
    @IBAction func actionPromocode(_ sender: Any) {
        self.delegate?.showPromoCode()
    }
    
    @IBAction func actionGroupStatus(_ sender: Any) {
        self.delegate?.showGroupStatus()
    }
    
    @IBAction func actionProductsLiked(_ sender: Any) {
        self.delegate?.showProductsLiked()
    }
    
    @IBAction func actionSupport(_ sender: Any) {
        self.delegate?.showSupport()
    }
}
