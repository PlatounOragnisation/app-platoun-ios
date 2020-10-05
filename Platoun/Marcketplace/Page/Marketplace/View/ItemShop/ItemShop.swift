//
//  ItemShop.swift
//  Platoun
//
//  Created by Flavian Mary on 10/01/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ItemShopDelegate {
    func onClicLike(productId: String, isLiked: Bool)
    func getViewController() -> UIViewController?
}

class ItemShop: UIView, ProductViewControllerDelegate {
    var view: UIView!
    var delegate: ItemShopDelegate?
    var parent: UIViewController?
    var product: ProductSummary?
    var productLiked: ProductLiked?
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var containerLikeButton: UIView!
    @IBOutlet weak var rateView: RateView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var soloPrice: PriceButton!
    @IBOutlet weak var groupPrice: PriceButton!
    @IBOutlet weak var secondaryPrice: UIStackView!
    @IBOutlet weak var secondarySolo: UILabel!
    @IBOutlet weak var secondaryGroup: UILabel!
    @IBOutlet weak var pourcentView: PourcentView!
    @IBOutlet weak var stackViewPrices: UIStackView!
    
    @IBInspectable
    var pricesIsVisible = true {
        didSet {
            stackViewPrices.isHidden = !self.pricesIsVisible
        }
    }
    
    @IBInspectable
    var secondaryPricesIsVisible = false {
        didSet {
            secondaryPrice.isHidden = !secondaryPricesIsVisible
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadViewFromNib()
    }
    
    func setup(product: ProductSummary, delegate: ItemShopDelegate, parent: UIViewController) {
        self.product = product
        self.parent = parent
        self.delegate = delegate
        
        self.title.text = product.name
        self.subTitle.text = product.brandName
        self.image.downloaded(from: product.pictureLink, contentMode: .scaleAspectFill)
        self.rateView.rate = 0 //product.rate
        self.rateView.rateNumber = 0//product.nbRate
        self.likeButton.state = productLike(product.id)
        self.soloPrice.price = product.price
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(product.price)€")
        attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        self.secondarySolo.attributedText = attributeString
        
        self.secondaryGroup.text = "\(product.groupPrice)€"
        
        self.groupPrice.price = product.groupPrice
        self.pourcentView.prct = product.percentage
    }
    
    func setup(product: ProductLiked, delegate: ItemShopDelegate, parent: UIViewController) {
        self.productLiked = product
        self.delegate = delegate
        self.parent = parent
        
        self.title.text = product.title
        self.subTitle.text = product.brandName
        self.image.downloaded(from: product.pictureLink)
        self.rateView.rate = 0 //product.rate
        self.rateView.rateNumber = 0//product.nbRate
        self.likeButton.state = .selected
        
        self.stackViewPrices.isHidden = true
        self.pourcentView.isHidden = true
        self.soloPrice.price = 0
        self.groupPrice.price = 0
        self.pourcentView.prct = 0
    }
    
    func loadViewFromNib() {
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
        self.image.image = nil
        self.containerLikeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicLike)))
        
        
        self.soloPrice.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicSoloPrice)))
        self.groupPrice.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicGroupPrice)))
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mainClic(sender:))))
    }
    
    @objc func mainClic(sender: UIGestureRecognizer) {
        guard let productId = self.product?.id ?? self.productLiked?.id else { return }
        let point = sender.location(in: self.containerLikeButton)
        if point.x >= 0 && point.x <= self.containerLikeButton.frame.width && point.y >= 0 && point.y <= self.containerLikeButton.frame.height {
            self.onClicLike()
        } else {
            guard let delegate = self.delegate else { return }
            
            let vc = ProductViewController.instance(productId: productId)
            vc.delegate = self
            delegate.getViewController()?.show(vc, sender: nil)
        }
    }
    
    func haveClickLike(productId: String, isLike: Bool) {
        guard productId == self.product?.id else { return }
        DispatchQueue.main.async {
            self.likeButton.state = isLike ? .selected : .noSelected
        }
    }
    
    @objc func onClicSoloPrice() {
        guard let product = self.product, let url = URL(string: product.link) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func onClicGroupPrice() {
        guard let product = self.product, let delegate = self.delegate else { return }
        let vc = JoinGroupViewController.instance(product: product, scrollBottom: false)
        delegate.getViewController()?.present(vc, animated: true, completion: nil)
    }
    
    @objc func onClicLike() {
        guard let productId = self.product?.id ?? self.productLiked?.id, self.likeButton.state != .processing, let userId = Auth.auth().currentUser?.uid else { return }
        
        let isLike = self.likeButton.state == .selected
        self.likeButton.state = .processing
        Interactor.shared.postLike(userId: userId, liked: !isLike, productId: productId) { value in
            let isLiked = value ?? isLike
            self.likeButton.state = isLiked ? .selected : .noSelected
            
            if self.parent is ProductsLikedViewController {
                self.delegate?.onClicLike(productId: productId, isLiked: isLiked)
            }
            
            
            (self.parent as? ContainerLikedProduct)?.updateLike()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.image.layer.cornerRadius = 10
        self.image.layer.masksToBounds = true
    }
}
