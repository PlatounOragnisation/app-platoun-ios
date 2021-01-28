//
//  CollectionViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 08/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class CategoryViewCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    
    @IBOutlet weak var itemView: ItemShop!
    
    func setup(product: ProductSummary, delegate: ItemShopDelegate, parent: UIViewController) {
        self.itemView.setup(
            product: product,
            delegate: delegate,
            parent: parent)
    }
    
    func setup(product: ProductLiked, delegate: ItemShopDelegate, parent: UIViewController) {
        self.itemView.setup(
            product: product,
            delegate: delegate,
            parent: parent)
    }
}
