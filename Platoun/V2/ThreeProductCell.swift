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
    
    var productClosure: ((ProductVote)->Void)?
    
    var product1: ProductVote?
    var product2: ProductVote?
    var product3: ProductVote?
    
    func setup(product1: ProductVote?, product2: ProductVote?, product3: ProductVote?, index: Int) {
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
        
        attribut(self.product1, in: self.product1ImageView, action: #selector(product1Click))
        attribut(self.product2, in: self.product2ImageView, action: #selector(product2Click))
        attribut(self.product3, in: self.product3ImageView, action: #selector(product3Click))
    }
    
    func attribut(_ product: ProductVote?, in imageView: UIImageView, action: Selector) {
        if let p = product {
            imageView.isHidden = false
            imageView.setImage(with: URL(string: p.image)!, placeholder: nil, options: .progressiveLoad)
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))

        } else {
            imageView.isHidden = true
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
