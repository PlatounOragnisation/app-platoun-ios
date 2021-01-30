//
//  ProductCardFooterView.swift
//  Platoun
//
//  Created by Flavian Mary on 28/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

class ProductCardFooterView: UIView {
    
    private let userProfileImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = ThemeColor.White
        image.clipsToBounds = true
        image.layer.cornerRadius = 25
        return image
        
    }()
    
    private let postedByLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeColor.c37474F
        label.font = UIFont.roboto(type: .medium, fontSize: 16)
        label.text = "posté par "
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeColor.c01BDAE
        label.font = UIFont.roboto(type: .medium, fontSize: 16)
        return label
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeColor.c9B9B9B
        label.font = UIFont.roboto(type: .regular, fontSize: 13)
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = ThemeColor.c37474F
        label.font = UIFont.roboto(type: .regular, fontSize: 15)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let seeMoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Voir plus.."
        label.textColor = ThemeColor.c9B9B9B
        label.font = UIFont.roboto(type: .regular, fontSize: 13)
        return label
    }()
    
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 25
        clipsToBounds = true
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func initialize() {
        addSubview(userProfileImageView)
        addSubview(postedByLabel)
        addSubview(userNameLabel)
        addSubview(productNameLabel)
        addSubview(commentLabel)
        addSubview(seeMoreLabel)
        
        
        let constraints = [
            userProfileImageView.heightAnchor.constraint(equalToConstant: 50),
            userProfileImageView.widthAnchor.constraint(equalTo: userProfileImageView.heightAnchor),
            userProfileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            userProfileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            
            productNameLabel.leftAnchor.constraint(equalTo: userProfileImageView.rightAnchor, constant: 15),
            productNameLabel.bottomAnchor.constraint(equalTo: userProfileImageView.bottomAnchor, constant: -6),
            
            postedByLabel.bottomAnchor.constraint(equalTo: productNameLabel.topAnchor, constant: -5),
            postedByLabel.leftAnchor.constraint(equalTo: productNameLabel.leftAnchor),
            
            userNameLabel.leftAnchor.constraint(equalTo: postedByLabel.rightAnchor),
            userNameLabel.bottomAnchor.constraint(equalTo: postedByLabel.bottomAnchor),
            
            commentLabel.leftAnchor.constraint(equalTo: userProfileImageView.leftAnchor),
            commentLabel.topAnchor.constraint(equalTo: userProfileImageView.bottomAnchor, constant: 8),
            commentLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -14),
            
            seeMoreLabel.leftAnchor.constraint(equalTo: userProfileImageView.leftAnchor),
            seeMoreLabel.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 8),
            seeMoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func update(with productCard: ProductCardModel) {
        userProfileImageView.setImage(with: URL(string: productCard.userImageUrl)!, placeholder: nil, options: .progressiveLoad)
        userNameLabel.text = "@\(productCard.userName)"
        productNameLabel.text = productCard.productName
        commentLabel.text = productCard.comment
    }
    
    override func layoutSubviews() {
//        let padding: CGFloat = 20
//        label.frame = CGRect(x: padding,
//                             y: bounds.height - label.intrinsicContentSize.height - padding,
//                             width: bounds.width - 2 * padding,
//                             height: label.intrinsicContentSize.height)
    }
}

extension NSAttributedString.Key {
    
    static var shadowAttribute: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
        return shadow
    }()
    
    static var titleAttributes: [NSAttributedString.Key: Any] = [
        // swiftlint:disable:next force_unwrapping
        NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 24)!,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]
    
    static var subtitleAttributes: [NSAttributedString.Key: Any] = [
        // swiftlint:disable:next force_unwrapping
        NSAttributedString.Key.font: UIFont(name: "Arial", size: 17)!,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]
}
