//
//  MarketplaceCategoryView.swift
//  Platoun
//
//  Created by Flavian Mary on 04/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

protocol MarketplaceCategoryViewAction {
    func seeAll(category: Category)
    func onClickLikeProduct(productId: String, isLiked: Bool)
    func getViewController() -> UIViewController?
}

@IBDesignable
class MarketplaceCategoryView: UIView, ItemShopDelegate {
    
    var view: UIView!
    var delegate: MarketplaceCategoryViewAction?
    
    @IBInspectable
    var hasHeader: Bool = true {
        didSet {
            headerView.isHidden = !self.hasHeader
        }
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var productStackView: UIStackView!
    
    var category: Category?
    
    @IBAction func actionSeeAll(_ sender: Any) {
        guard let category = self.category else { return }
        self.delegate?.seeAll(category: category)
    }
    
    func getHeight() -> CGFloat {
        let ratio: CGFloat = 170 / 275
        
        let width: CGFloat = UIScreen.main.bounds.width / 2.2
        
        let height: CGFloat = (width / ratio) + (hasHeader ? 70 : 0)
        
        return height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadViewFromNib()
    }
    
    private func loadViewFromNib() {
        let bundle = Bundle.platoun
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        self.view = view
    }
    
    func onClicLike(productId: String, isLiked: Bool) {
        self.delegate?.onClickLikeProduct(productId: productId, isLiked: isLiked)
    }
    
    func getViewController() -> UIViewController? {
        return self.delegate?.getViewController()
    }
    
    func setup(by category: Category?, and products: [ProductSummary], parent: UIViewController, priceIsHidden: Bool = false) {
        self.category = category
        
        self.headerView.isHidden = self.category == nil
        
        if let cat = category {
            titleLabel.text = cat.name
            iconImageView.downloaded(from: cat.icon)
        }
        
        var count = 0
        products.enumerated().forEach { (index, product) in
            let viewExist = (productStackView.arrangedSubviews.count - 1) > index
            
            if !viewExist {
                let shopView = ItemShop(frame: .zero)
                productStackView.addArrangedSubview(shopView)
                shopView.translatesAutoresizingMaskIntoConstraints = false
                
                let ratio: CGFloat = 170 / 275
                
                let width: CGFloat = UIScreen.main.bounds.size.width / 2.2
                
                shopView.widthAnchor.constraint(equalToConstant: width).isActive = true
                shopView.heightAnchor.constraint(equalToConstant: width/ratio).isActive = true
            }
            
            if let shopView = productStackView.arrangedSubviews[index] as? ItemShop {
                shopView.pricesIsVisible = !priceIsHidden
                shopView.secondaryPricesIsVisible = priceIsHidden
                shopView.setup(
                    product: product,
                    delegate: self, parent: parent)
            }
            
            count += 1
        }
        
        while count < self.productStackView.arrangedSubviews.count, let last = self.productStackView.arrangedSubviews.last {
            last.removeFromSuperview()
        }
    }
}
