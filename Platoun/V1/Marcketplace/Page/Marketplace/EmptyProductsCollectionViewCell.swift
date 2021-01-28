//
//  EmptyProductsCollectionViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 23/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class EmptyProductsCollectionViewCell: UICollectionViewCell {
    static let identifier = "EmptyProductsCollectionViewCell"
    
    @IBOutlet weak var modifyFilterButton: BorderedButton!
    
    var showFilterPage: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        modifyFilterButton.addTarget(self, action: #selector(modifyFilterAction), for: .touchUpInside)
    }
    
    @objc func modifyFilterAction() {
        self.showFilterPage?()
    }
}
