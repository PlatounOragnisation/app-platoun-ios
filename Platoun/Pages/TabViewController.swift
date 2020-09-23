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
        self.selectedIndex = 3
        Platoun.setEnv(env: .develop)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.connexion()
    }
    
    func connexion() {
        if let user = Auth.auth().currentUser {
            if let actualVc = self.viewControllers?[1], !(actualVc is DrawerController) {
                let vc = Platoun.getViewController(userId: user.uid)
                vc.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ic_tab_marketplace"), selectedImage: UIImage(named: "ic_tab_marketplace_original"))
                vc.tabBarItem.titlePositionAdjustment = .zero
                self.viewControllers?[1] = vc
            }
        } else {
            LoginViewController.show(in: self) { isConnected in
                if !isConnected {
                    UIKitUtils.showAlert(in: self, message: "Vous devez être connecter pour continuer") {
                        self.connexion()
                    }
                }
            }
        }
    }
}
