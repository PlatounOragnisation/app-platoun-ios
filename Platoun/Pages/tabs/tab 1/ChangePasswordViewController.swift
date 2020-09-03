//
//  ChangePasswordViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 31/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    static func getInstance() -> ChangePasswordViewController {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePreferredContentSize(with: self.traitCollection)
        
        let userType = Auth.auth().currentUser?.authentication
        
        print(userType)
        
        // Do any additional setup after loading the view.
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updatePreferredContentSize(with: newCollection)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(
            width: self.view.bounds.size.width,
            height: traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact ? 334 : 520)
    }
    @IBAction func saveNewPasswordAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
