//
//  PUIViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 08/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit


class PUIViewController: LightViewController, UIAdaptivePresentationControllerDelegate {
    
    func newPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.presentationController?.delegate = self
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewBecomeFirst()
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        viewBecomeFirst()
    }
    
    func viewBecomeFirst() {}
}
