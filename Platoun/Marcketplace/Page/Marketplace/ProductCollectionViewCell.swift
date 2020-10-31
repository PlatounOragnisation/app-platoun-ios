//
//  ProductCollectionViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 22/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProductCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProductCollectionViewCell"

    var product: ProductSummary?
    weak var parent: UIViewController?
    var currentState: LikeState = .noLike
    @IBOutlet weak var borderLessContainer: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLoading: UIActivityIndicatorView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var pourcentView: UIView!
    @IBOutlet weak var pourcentLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloPriceLabel: UILabel!
    @IBOutlet weak var groupPriceLabel: UILabel!
    @IBOutlet weak var soloPriceButton: UIView!
    @IBOutlet weak var groupPriceButton: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        soloPriceButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.soloPriceAction(_:))))
        groupPriceButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.groupPriceAction(_:))))
        borderLessContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick)))
        likeLoading.isHidden = true
    }
    
    func setup(product: ProductSummary, parent: UIViewController) {
        self.product = product
        self.parent = parent
        
        titleLabel.text = product.name
        subtitleLabel.text = product.brandName
        productImageView.setImage(with: URL(string: product.pictureLink), placeholder: nil, options: .progressiveLoad)
        self.pourcentLabel.text = "- \(product.percentage)%"
        soloPriceLabel.text = "\(product.price)€"
        groupPriceLabel.text = "\(product.groupPrice)€"
        groupPriceButton.isHidden = !product.withReduc
        pourcentView.isHidden = !product.withReduc
        currentState = LikeState.convert(state: productLike(product.id))
        self.updateBackgroundLikeButton()
    }
    
    enum LikeState {
        case like
        case noLike
        case processing
        
        static func convert(state: LikeButton.State) -> LikeState {
            switch state {
            case .selected:
                return .like
            case .processing:
                return .processing
            case .noSelected:
                return .noLike
            }
        }
    }
    
    func updateBackgroundLikeButton() {
        
        let image: UIImage?
        switch self.currentState {
        case .like:
            likeLoading.stopAnimating()
            image = UIImage(named: "ic-liked-button")
        case .noLike:
            likeLoading.stopAnimating()
            image = UIImage(named: "ic-noliked-button")
        case .processing:
            likeLoading.isHidden = false
            likeLoading.startAnimating()
            image = UIImage(named: "ic-like-button-loading")
        }
        self.likeButton.setBackgroundImage(image, for: .normal)
    }

    @IBAction func likeAction(_ sender: Any) {
        guard let productId = self.product?.id, currentState != .processing, let userId = Auth.auth().currentUser?.uid else { return }
        
        let isLike = self.currentState == .like
        self.currentState = .processing

        updateBackgroundLikeButton()
        Interactor.shared.postLike(userId: userId, liked: !isLike, productId: productId) { value in
            let isLiked = value ?? isLike
            self.currentState = isLiked ? .like : .noLike
            self.updateBackgroundLikeButton()
            
            (self.parent as? ContainerLikedProduct)?.updateLike()
        }
    }
    
    @IBAction func soloPriceAction(_ sender: Any) {
        guard let product = self.product, let url = URL(string: product.link) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func groupPriceAction(_ sender: Any) {
        guard let product = self.product else { return }
        let vc = JoinGroupViewController.instance(product: product, scrollBottom: false)
        self.parent?.present(vc, animated: true, completion: nil)
    }
    
    @objc func itemClick() {
        guard let product = self.product else { return }
        let vc = ProductViewController.instance(productId: product.id)
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}
