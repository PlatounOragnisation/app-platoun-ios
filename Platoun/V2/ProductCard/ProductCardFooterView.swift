//
//  ProductCardFooterView.swift
//  Platoun
//
//  Created by Flavian Mary on 28/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

protocol FooterDelegate {
    func userNameTapAction()
}

class ProductCardFooterView: UIView {
    
    var delegate: FooterDelegate?
    
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
    
    private let askQuestionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("  Poser une question", for: .normal)
        button.titleLabel?.font = UIFont.roboto(type: .regular, fontSize: 14)
        button.setTitleColor(ThemeColor.c37474F, for: .normal)
        button.setImage(UIImage(named:"ic-ask"), for: .normal)
        button.isHidden = true
        button.alpha = 0
        return button
    }()
    
    private let lineButton: UIImageView = {
        let image = UIImageView(image: UIImage(named: "img-bottom-ligne-select"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        return image
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 25
        clipsToBounds = true
        isOpaque = false
    }
    
    func increase() -> (()->Void, ()->Void, ()->Void) {
        return (
            {
                self.commentLabel.numberOfLines = 0
            },
            {
                self.lignInvisible?.isActive = false
                self.lignVisible?.isActive = true
                
                self.lineButton.isHidden = false
                self.askQuestionButton.isHidden = false
                self.askQuestionButton.alpha = 1
                self.seeMoreLabel.alpha = 0
            },
            {
                self.seeMoreLabel.isHidden = true
            }
        )
    }
    
    func decrease() -> (()->Void, ()->Void, ()->Void) {
        
        return (
            {
                self.commentLabel.numberOfLines = 1
            },
            {
                self.lignInvisible?.isActive = true
                self.lignVisible?.isActive = false
                
                self.askQuestionButton.alpha = 0
                self.seeMoreLabel.isHidden = false
                self.seeMoreLabel.alpha = 1
            }, {
                self.lineButton.isHidden = true
                self.askQuestionButton.isHidden = true
            }
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    var lignVisible: NSLayoutConstraint?
    var lignInvisible: NSLayoutConstraint?
    
    func initialize() {
        lignVisible = lineButton.widthAnchor.constraint(equalTo: askQuestionButton.widthAnchor, constant: -15)
        lignInvisible = lineButton.widthAnchor.constraint(equalToConstant: 0)
        
        addSubview(userProfileImageView)
        addSubview(postedByLabel)
        addSubview(userNameLabel)
        addSubview(productNameLabel)
        addSubview(commentLabel)
        addSubview(seeMoreLabel)
        addSubview(askQuestionButton)
        addSubview(lineButton)
        
        
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
            seeMoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            askQuestionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            askQuestionButton.heightAnchor.constraint(equalToConstant: 25),
            askQuestionButton.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 13),
            askQuestionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            
            lineButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 11),
            lineButton.topAnchor.constraint(equalTo: askQuestionButton.bottomAnchor, constant: 0),
            lineButton.heightAnchor.constraint(equalToConstant: 11),
            lignInvisible!
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userNameDidTap)))
    }
    
    @objc func userNameDidTap() {
        self.delegate?.userNameTapAction()
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
