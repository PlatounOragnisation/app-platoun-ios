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

protocol ReloadedViewController {
    func reload()
}

class Tab1ViewController: UIViewController, ReloadedViewController {
    
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var paramButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Mon compte"
        
        codeButton.setTitle("Codes débloqués", for: .normal)
        groupButton.setTitle("Mes groupes en attentes", for: .normal)
        likeButton.setTitle("Ma liste de favoris", for: .normal)
        paramButton.setTitle("Paramètres", for: .normal)
        supportButton.setTitle("Support", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.profilImageView.round()
        
        self.loadUserInfo()
        
        self.navigationController?.navigationBar.isHidden = true
        self.initializeBackgroundColor(view: self.view)
    }
    
    func reload() {
        self.loadUserInfo()
    }
    
    func loadUserInfo() {
        let profilImage = Auth.auth().currentUser?.photoURL
        if let url = profilImage {
            self.profilImageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.profilImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
    
    
    @IBAction func codeButtonAction(_ sender: Any) {
        let vc = PromocodesViewController.instance(isForPromocode: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func groupButtonAction(_ sender: Any) {
        let vc = PromocodesViewController.instance(isForPromocode: false)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func supportButtonAction(_ sender: Any) {
        guard let url = URL(string: "http://platoun.com/mentions-legales/") else { return }
        UIApplication.shared.open(url)
    }
    
}
