//
//  CategoryCollectionViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 22/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    var category: Category?
    var products: [ProductSummary]?
    weak var parent: UIViewController?
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var categoryIconView: UIImageView!
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var seeAllLabel: UILabelLocalized!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeAllAction)))
    }
    
    func setup(category: Category, products: [ProductSummary], parent: UIViewController) {
        self.category = category
        self.products = products
        self.parent = parent
        
        categoryTitleLabel.text = category.name
        categoryIconView.setImage(with: URL(string: category.icon), placeholder: nil, options: .progressiveLoad)
    }

    @objc func seeAllAction() {
        guard let category = self.category, let products = self.products else { return }
        let vc = CategoryViewController.instance(category: category, products: products)
        
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}
