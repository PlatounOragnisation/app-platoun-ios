//
//  SwipeViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 26/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit
import Shuffle

class SwipeViewController: UIViewController {
    
    private let cardStack = SwipeCardStack()
    private let buttonStackView = ButtonStackView()
    
    
    private let cardModels: [ProductCardModel] = [
        ProductCardModel(userName: "UserName1", productName: "ProductName1", comment: "Comment1 très long pour voir si c'est bien sur une seule ligne", productImageUrl: "https://offautan-uc1.azureedge.net/-/media/images/off/ph/products-en/products-landing/landing/off_overtime_product_collections_large_2x.jpg?la=en-ph", userImageUrl: "https://www.nicesnippets.com/demo/profile-1.jpg"),
        ProductCardModel(userName: "UserName2", productName: "ProductName2", comment: "Comment2", productImageUrl: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg", userImageUrl: "https://www.nicesnippets.com/demo/profile-3.jpg"),
        ProductCardModel(userName: "UserName1", productName: "ProductName1", comment: "Comment1", productImageUrl: "https://offautan-uc1.azureedge.net/-/media/images/off/ph/products-en/products-landing/landing/off_overtime_product_collections_large_2x.jpg?la=en-ph", userImageUrl: "https://www.nicesnippets.com/demo/profile-1.jpg"),
        ProductCardModel(userName: "UserName2", productName: "ProductName2", comment: "Comment2", productImageUrl: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg", userImageUrl: "https://www.nicesnippets.com/demo/profile-3.jpg"),
        ProductCardModel(userName: "UserName1", productName: "ProductName1", comment: "Comment1", productImageUrl: "https://offautan-uc1.azureedge.net/-/media/images/off/ph/products-en/products-landing/landing/off_overtime_product_collections_large_2x.jpg?la=en-ph", userImageUrl: "https://www.nicesnippets.com/demo/profile-1.jpg"),
        ProductCardModel(userName: "UserName2", productName: "ProductName2", comment: "Comment2", productImageUrl: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg", userImageUrl: "https://www.nicesnippets.com/demo/profile-3.jpg"),
        ProductCardModel(userName: "UserName1", productName: "ProductName1", comment: "Comment1", productImageUrl: "https://offautan-uc1.azureedge.net/-/media/images/off/ph/products-en/products-landing/landing/off_overtime_product_collections_large_2x.jpg?la=en-ph", userImageUrl: "https://www.nicesnippets.com/demo/profile-1.jpg"),
        ProductCardModel(userName: "UserName2", productName: "ProductName2", comment: "Comment2", productImageUrl: "https://cdn.pixabay.com/photo/2020/05/26/09/32/product-5222398_960_720.jpg", userImageUrl: "https://www.nicesnippets.com/demo/profile-3.jpg")
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.initPlatounTheme(isTransparent: true)
        
        self.navigationItem.initTitleItem()
        self.navigationItem.initLeftItem(target: self, actionTap: #selector(actionTapProfil))
        self.navigationItem.initRightItem(target: self, actionTap: #selector(actionTapRing))
    }
    @objc private func actionTapProfil() {
        
    }
    @objc private func actionTapRing() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self
        
        layoutButtonStackView()
        layoutCardStackView()
        
    }
    
    func card(fromImage image: UIImage) -> SwipeCard {
        let card = SwipeCard()
        card.swipeDirections = [.left, .right]
        card.content = UIImageView(image: image)
        
        let leftOverlay = UIView()
        leftOverlay.backgroundColor = .green
        
        let rightOverlay = UIView()
        rightOverlay.backgroundColor = .red
        
        card.setOverlays([.left: leftOverlay, .right: rightOverlay])
        
        return card
    }
    
    private func layoutButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                               bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               right: view.safeAreaLayoutGuide.rightAnchor,
                               paddingLeft: 24,
                               paddingBottom: 12,
                               paddingRight: 24)
    }
    
    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            cardStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            cardStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            cardStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            cardStack.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1, constant: -70 - 58 - 16 - 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

extension SwipeViewController: ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SwipeCard()
        card.footerHeight = 0
        card.swipeDirections = [.left, .up, .right]
        for direction in card.swipeDirections {
            card.setOverlay(ProductCardOverlay(direction: direction), forDirection: direction)
        }
        
        let model = cardModels[index]
        card.content = ProductCardContentView()
        (card.content as! ProductCardContentView).update(with: model)
//        card.footer = ProductCardFooterView(withTitle: "\(model.productName)", subtitle: model.userName)
        
        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return cardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Swiped all cards!")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(cardModels[index].productName)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("Swiped \(direction) on \(cardModels[index].productName)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
    }
    
    func didTapButton(button: BottomButton) {
        switch button.tag {
        case 1:
          cardStack.undoLastSwipe(animated: true)
        case 2:
          cardStack.swipe(.left, animated: true)
        case 3:
          cardStack.swipe(.up, animated: true)
        case 4:
          cardStack.swipe(.right, animated: true)
        case 5:
          cardStack.reloadData()
        default:
          break
        }
      }
}
