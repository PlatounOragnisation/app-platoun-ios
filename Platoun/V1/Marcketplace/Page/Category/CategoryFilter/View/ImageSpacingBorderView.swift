//
//  ImageSpacingBorderView.swift
//  Platoun
//
//  Created by Flavian Mary on 09/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol ImageSpacingBorderViewAction {
    func onClicImage(view: ImageSpacingBorderView, isSelected: Bool)
}

class ImageSpacingBorderView: UIView {
    
    var delegate: ImageSpacingBorderViewAction?
    
    @IBInspectable
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    @IBInspectable
    var isSelected: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(imageView)
        
        let constraints = [
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4)
        ]
        NSLayoutConstraint.activate(constraints)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClic)))
    }
    
    @objc func onClic() {
        self.isSelected = !self.isSelected
        self.delegate?.onClicImage(view: self, isSelected: self.isSelected)
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = isSelected ? self.tintColor.cgColor : UIColor.clear.cgColor
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.borderWidth = 1
    }
}
