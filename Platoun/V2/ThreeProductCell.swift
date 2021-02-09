//
//  ProductCollectionViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 08/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

class ThreeProductCell: UITableViewCell {
    static let Odd = "productCellOdd"
    static let Even = "productCellEven"
    
    @IBOutlet weak var product1ImageView: UIImageView!
    @IBOutlet weak var product2ImageView: UIImageView!
    @IBOutlet weak var product3ImageView: UIImageView!
    
    var productClosure: ((ProductV2)->Void)?
    
    var product1: ProductV2?
    var product2: ProductV2?
    var product3: ProductV2?
    
    func setup(product1: ProductV2?, product2: ProductV2?, product3: ProductV2?, index: Int) {
        self.product1 = product1
        self.product2 = product2
        self.product3 = product3
        
        if index == 0 {
            self.product1ImageView.roundCorners(corners: [.topLeft], radius: 16)
            self.product2ImageView.roundCorners(corners: [.topRight], radius: 16)
        } else {
            self.product1ImageView.layer.mask = nil
            self.product2ImageView.layer.mask = nil
        }
        
        
        if let p = self.product1 {
            self.product1ImageView.isHidden = false
            self.product1ImageView.setImage(with: URL(string: p.productImage)!, placeholder: nil, options: .progressiveLoad)
            self.product1ImageView.isUserInteractionEnabled = true
            self.product1ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(product1Click)))
        } else {
            self.product1ImageView.isHidden = true
        }
        
        if let p = self.product2 {
            self.product2ImageView.isHidden = false
            self.product2ImageView.setImage(with: URL(string: p.productImage)!, placeholder: nil, options: .progressiveLoad)
            self.product2ImageView.isUserInteractionEnabled = true
            self.product2ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(product2Click)))
        } else {
            self.product2ImageView.isHidden = true
        }
        
        if let p = self.product3 {
            self.product3ImageView.isHidden = false
            self.product3ImageView.setImage(with: URL(string: p.productImage)!, placeholder: nil, options: .progressiveLoad)
            self.product3ImageView.isUserInteractionEnabled = true
            self.product3ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(product3Click)))

        } else {
            self.product3ImageView.isHidden = true
        }
    }
    
    @objc func product1Click() {
        guard let p = self.product1 else { return }
        self.productClosure?(p)
    }
    @objc func product2Click() {
        guard let p = self.product2 else { return }
        self.productClosure?(p)
    }
    @objc func product3Click() {
        guard let p = self.product3 else { return }
        self.productClosure?(p)
    }
    
    
}

extension UIView {
    fileprivate func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
