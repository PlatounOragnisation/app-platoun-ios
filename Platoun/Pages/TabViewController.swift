//
//  TabViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 24/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class TabViewController: UITabBarController {
    let loginSegue = "displayAuth"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.selectedIndex = 0
        let vc = UINavigationController(rootViewController: MarketplaceViewController.instance())
        vc.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ic_tab_marketplace"), selectedImage: UIImage(named: "ic_tab_marketplace_original"))
        vc.tabBarItem.titlePositionAdjustment = .zero
        self.viewControllers?[1] = vc
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.connexion()
    }
    
    func connexion() {
        if Auth.auth().currentUser == nil {
            LoginViewController.show(in: self) { isConnected in
                if !isConnected {
                    UIKitUtils.showAlert(in: self, message: "Vous devez être connecter pour continuer") {
                        self.connexion()
                    }
                } else {
                    
                    let reloader: ReloadedViewController?
                    if let nav = self.selectedViewController as? UINavigationController {
                        reloader = nav.topViewController as? ReloadedViewController
                    } else {
                        reloader = self.selectedViewController as? ReloadedViewController
                    }
                    reloader?.reload()
                }
            }
        }
    }
}

extension TabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        if viewController is DrawerController {
            Platoun.update(userId: user.uid)
        }
        return true
    }
}
