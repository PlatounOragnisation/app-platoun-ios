//
//  SuccessViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 15/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class SuccessViewController: LightViewController {
    
    static func instance(promocode: String, link: String) -> SuccessViewController {
        let viewController = SuccessViewController.instanceStoryboard()
        viewController.promocode = promocode
        viewController.link = link
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
    
    
    var promocode: String!
    var link: String!
    
    @IBOutlet weak var promocodeButton: BorderedButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promocodeButton.setTitle(promocode.uppercased(), for: .normal)
    }
    
    @IBAction func promocodeTap(_ sender: Any) {
        UIPasteboard.general.string = promocode
        guard let url = URL(string: link) else { return }
        
        let alert = UIAlertController(title: nil, message: "The promo code has been copied to your clipboard. You will now be redirected to the merchant site.".localise(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK".localise(), style: .default, handler: { _ in
            UIApplication.shared.open(url)
        }))
        
        self.present(alert, animated: true)
    }
    
    
    @IBAction func backToShoppingTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
