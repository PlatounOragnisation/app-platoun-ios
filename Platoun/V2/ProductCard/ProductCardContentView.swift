//
//  ProductCardContentView.swift
//  Platoun
//
//  Created by Flavian Mary on 28/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

class ProductCardContentView: UIView {
        
    private let backgroundView: UIView = {
        let background = UIView()
        background.backgroundColor = ThemeColor.White
        background.clipsToBounds = true
        background.layer.cornerRadius = 25
        return background
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let productCardFooter: ProductCardFooterView = {
        let footer = ProductCardFooterView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        return footer
    }()
    
    //  private let gradientLayer: CAGradientLayer = {
    //    let gradient = CAGradientLayer()
    //    gradient.colors = [UIColor.black.withAlphaComponent(0.01).cgColor,
    //                       UIColor.black.withAlphaComponent(0.8).cgColor]
    //    gradient.startPoint = CGPoint(x: 0.5, y: 0)
    //    gradient.endPoint = CGPoint(x: 0.5, y: 1)
    //    return gradient
    //  }()
    
    init() {
        super.init(frame: .zero)
        initialize()
        productCardFooter.initialize()
    }
    
    func update(with productCard: ProductCardModel) {
        imageView.setImage(with: URL(string: productCard.productImageUrl)!, placeholder: nil, options: .progressiveLoad)
        productCardFooter.update(with: productCard)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private func initialize() {
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(productCardFooter)
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            
            imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            imageView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            imageView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor),

            productCardFooter.topAnchor.constraint(equalTo: imageView.bottomAnchor),

            productCardFooter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            productCardFooter.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            productCardFooter.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),            
        ]
        
        NSLayoutConstraint.activate(constraints)        
        applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    }
}
