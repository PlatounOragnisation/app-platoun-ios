//
//  Tab1ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

fileprivate extension UIImageView {
    func round() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }
}

class Tab1ViewController: UIViewController { 
    
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Mon compte"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.profilImageView.round()
        
        let profilImage = Auth.auth().currentUser?.photoURL
        if let url = profilImage {
            self.profilImageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.profilImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
        
        self.navigationController?.navigationBar.isHidden = true
        self.initializeBackgroundColor(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        AuthenticationLogout()
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()
        
    }
    
    private func initializeBackgroundColor(view: UIView) {
        let layer0 = CAGradientLayer()

        layer0.colors = [
            ThemeColor.BackgroundGradient1.cgColor,
            ThemeColor.BackgroundGradient2.cgColor,
            ThemeColor.BackgroundGradient2.cgColor
        ]

        layer0.locations = [0, 1, 1]

        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)

        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)

        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.94, b: -0.91, c: 0.91, d: 1, tx: -0.45, ty: 0.46))

        layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)

        layer0.position = view.center

        view.layer.insertSublayer(layer0, at: 0)


        view.layer.cornerRadius = 2.04
    }
    
}
