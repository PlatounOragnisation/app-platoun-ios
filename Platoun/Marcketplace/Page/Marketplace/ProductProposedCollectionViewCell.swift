//
//  ProductCollectionViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 22/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProductProposedCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProductProposedCollectionViewCell"

    var product: ProductSummary?
    weak var parent: UIViewController?
    var currentState: LikeState = .noLike
    @IBOutlet weak var borderLessContainer: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLoading: UIActivityIndicatorView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var pourcentLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloPriceLabel: UILabel!
    @IBOutlet weak var groupPriceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        
        
        productView.isHidden = !product.withReduc
        groupPriceLabel.isHidden = !product.withReduc
        if !product.withReduc {
            soloPriceLabel.text = "\(product.price)€"
        } else {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(product.price)€")
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            soloPriceLabel.attributedText = attributeString
            groupPriceLabel.text = "\(product.groupPrice)€"
        }
        
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
    
    @objc func itemClick() {
        guard let product = self.product else { return }
        let vc = ProductViewController.instance(productId: product.id)
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}
