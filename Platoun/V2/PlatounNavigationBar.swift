//
//  PlatounNavigationBar.swift
//  Platoun
//
//  Created by Flavian Mary on 26/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit

extension UINavigationController {
    func initPlatounTheme(isTransparent: Bool = true) {
        let image = UIImage(named: "img-navigation-bar")
        self.navigationBar.setBackgroundImage(isTransparent ? UIImage() : image, for: .default)
        self.navigationBar.tintColor = ThemeColor.White
        
        if isTransparent {
            self.navigationBar.shadowImage = UIImage()
        }
    }
}


extension UINavigationItem {
    
    func initLeftItem(target: Any, actionTap: Selector) {
        let image = UIImage(named: "ic-profil")
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: actionTap)
        self.leftBarButtonItem = barButtonItem
    }
    
    func initRightItem(target: Any, actionTap: Selector) {
        let image = UIImage(named: "ic-ring")
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: actionTap)
        
        self.rightBarButtonItem = barButtonItem
    }
    
    func initTitleItem() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 25))
        titleView.translatesAutoresizingMaskIntoConstraints = false

        
        let swipeButton = getSwipeButton()
        let separatorView = getSeparatorView()
        let shopButton = getShopButton()
        
        
        titleView.addSubview(swipeButton)
        titleView.addSubview(separatorView)
        titleView.addSubview(shopButton)
        
        let constraints = [
            swipeButton.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            swipeButton.topAnchor.constraint(equalTo: titleView.topAnchor),
            swipeButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            swipeButton.heightAnchor.constraint(equalToConstant: 25),
            swipeButton.widthAnchor.constraint(equalToConstant: 65),
            
            swipeButton.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor),

            separatorView.topAnchor.constraint(equalTo: titleView.topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 25),
            separatorView.widthAnchor.constraint(equalToConstant: 25),
            
            separatorView.trailingAnchor.constraint(equalTo: shopButton.leadingAnchor),

            shopButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            shopButton.topAnchor.constraint(equalTo: titleView.topAnchor),
            shopButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            shopButton.heightAnchor.constraint(equalToConstant: 25),
            shopButton.widthAnchor.constraint(equalToConstant: 65)
        ]
        
        NSLayoutConstraint.activate(constraints)
                
        self.titleView = titleView
        
        shopButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionTapShop)))
    }
    
    @objc private func actionTapShop() {
        (UIApplication.shared.delegate as! AppDelegate).displayV1()
    }
    
    private func getSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "|"
        label.textAlignment = .center
        label.textColor = ThemeColor.White
        
        label.font = UIFont.helvetica(type: .bold, fontSize: 18)
        
        view.addSubview(label)
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)

        
        return view
    }
    
    private func getSwipeButton() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let platounLabel = UILabel()
        platounLabel.translatesAutoresizingMaskIntoConstraints = false
        platounLabel.text = "Platoun"
        platounLabel.font = UIFont.baloo(type: .regular, fontSize: 6)
        platounLabel.textColor = ThemeColor.White
        
        view.addSubview(platounLabel)
        
        let swipeLabel = UILabel()
        swipeLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeLabel.text = "Swipe"
        swipeLabel.font = UIFont.roboto(type: .medium, fontSize: 15)
        swipeLabel.textColor = ThemeColor.White

        view.addSubview(swipeLabel)
        
        let image = UIImage(named: "ic-swipe")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = ThemeColor.White

        view.addSubview(imageView)
        
        let constraints = [
            platounLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            platounLabel.topAnchor.constraint(equalTo: view.topAnchor),
            swipeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swipeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return view
    }
    
    private func getShopButton() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let platounLabel = UILabel()
        platounLabel.translatesAutoresizingMaskIntoConstraints = false
        platounLabel.text = "Platoun"
        platounLabel.font = UIFont.baloo(type: .regular, fontSize: 6)
        platounLabel.textColor = ThemeColor.White.withAlphaComponent(0.5)
        
        view.addSubview(platounLabel)
        
        let swipeLabel = UILabel()
        swipeLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeLabel.text = "Shop"
        swipeLabel.font = UIFont.roboto(type: .medium, fontSize: 15)
        swipeLabel.textColor = ThemeColor.White.withAlphaComponent(0.5)

        view.addSubview(swipeLabel)
        let image = UIImage(named: "ic-shop")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = ThemeColor.White.withAlphaComponent(0.5)
        
        view.addSubview(imageView)
        
        let constraints = [
            platounLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            platounLabel.topAnchor.constraint(equalTo: view.topAnchor),
            swipeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swipeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return view
    }
}
