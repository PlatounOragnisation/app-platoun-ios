//
//  UpgradeViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 02/11/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class UpgradeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Hello !\nUne mise à jour est requise ! "
        textLabel.text = "Afin d’assurer un fonctionnement optimal de l’application, nous t’invitons à télécharger la dernière version.\n\nÀ tout de suite sur Platoun !"
    }
    
    @IBAction func upgradeAction(_ sender: Any) {
        UIApplication.shared.open(Config.appStoreURL)
    }
    
}
