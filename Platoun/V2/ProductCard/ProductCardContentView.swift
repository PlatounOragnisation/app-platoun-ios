//
//  ProductCardContentView.swift
//  Platoun
//
//  Created by Flavian Mary on 28/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

protocol ActionCardDelegate {
    func userNameTapAction()
    func shareImage(image: UIImage)
}

extension UIView {
    
    func createImage() -> UIImage {

        let rect: CGRect = CGRect(
            x: self.frame.origin.x - 20, y: self.frame.origin.y - 20, width: self.frame.width + 40, height: self.frame.height + 40
        )
        
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img

    }
    
}

class ProductCardContentView: UIView {
    
    var delegate: ActionCardDelegate?
    
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
    
    private lazy var productCardFooter: ProductCardFooterView = {
        let footer = ProductCardFooterView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.delegate = self
        return footer
    }()
    
    private let shareImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "ic-share-product"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        image.alpha = 0
        image.isUserInteractionEnabled = true
        return image
    }()
    
    @objc func share() {
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addRect(UIScreen.main.bounds)
            ctx.cgContext.drawPath(using: .fill)

            let rect = CGRect(
                x: (width - self.backgroundView.bounds.size.width) / 2 ,
                y: (height - self.backgroundView.bounds.size.height) / 2,
                width: self.backgroundView.bounds.size.width,
                height: self.backgroundView.bounds.size.height
            )
            
            self.backgroundView.drawHierarchy(in: rect, afterScreenUpdates: true)
        }
        
        self.delegate?.shareImage(image: image)
    }
    
    init() {
        super.init(frame: .zero)
        initialize()
        productCardFooter.initialize()
        
        shareImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
    }
    
    var isIncrease = false
    
    func toogleIncrease() -> (()->Void, ()->Void, ()->Void){
        if isIncrease {
            return self.decrease()
        } else {
            return self.increase()
        }
    }
    func increase() -> (()->Void, ()->Void, ()->Void) {
        isIncrease = true
        
        let (b,a,c) = self.productCardFooter.increase()
        
        return (
            {
                b()
                
            },{
                a()
                self.shareImage.isHidden = false
                self.shareImage.alpha = 1
            },{
                c()
                
            }
        )
    }
    func decrease() -> (()->Void, ()->Void, ()->Void) {
        isIncrease = false
        let (b,a,c) = self.productCardFooter.decrease()
        
        return (
            {
                b()
                
            },{
                a()
                self.shareImage.alpha = 0
            },{
                c()
                self.shareImage.isHidden = true
            }
        )
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
        backgroundView.addSubview(shareImage)
        
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            
            productCardFooter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            productCardFooter.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            productCardFooter.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            
            productCardFooter.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            
            imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            imageView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            
            shareImage.heightAnchor.constraint(equalToConstant: 40),
            shareImage.widthAnchor.constraint(equalToConstant: 40),
            shareImage.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -12),
            shareImage.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -15)
        ]
        
        NSLayoutConstraint.activate(constraints)        
        applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    }
}

extension ProductCardContentView: FooterDelegate {
    func userNameTapAction() {
        self.delegate?.userNameTapAction()
    }
}
