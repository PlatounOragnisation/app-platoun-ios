//
//  FilterCell.swift
//  Platoun
//
//  Created by Flavian Mary on 28/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    static let identifier = "FilterCell"
    
    @IBOutlet weak var resultLabel: UILabel!
    
    func setup(count: Int) {
        
        let text: String
        if count > 1 {
            text = "Results: %d items"
        } else {
            text = "Results: %d item"
        }
        self.resultLabel.text = text.localise(count)
    }
}
