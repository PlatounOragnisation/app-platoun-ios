//
//  RoundedLabel.swift
//  Platoun
//
//  Created by Flavian Mary on 09/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol RoundedLabelAction {
    func onClicLabel(view: RoundedLabel, isSelected: Bool)
}

@IBDesignable
class RoundedLabel: UILabel {
    
    var delegate: RoundedLabelAction?
    
    @IBInspectable
    var isSelected: Bool = true {
        didSet {
            layoutIfNeeded()
            self.setNeedsLayout()
        }
    }

    @IBInspectable
    var unselectedColor: UIColor = .black
    
    @IBInspectable
    var unselectedTextColor: UIColor = .black
    
    @IBInspectable
    var selectedTextColor: UIColor = .white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClic)))
    }
    
    @objc func onClic() {
        self.isSelected = !self.isSelected
        self.delegate?.onClicLabel(view: self, isSelected: self.isSelected)
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.layer.borderColor = self.isSelected ? self.tintColor.cgColor : self.unselectedColor.cgColor
        
        self.textColor = self.isSelected ? self.selectedTextColor : self.unselectedTextColor
        
        self.backgroundColor = self.isSelected ? self.tintColor : UIColor.clear
        
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
    }

}
