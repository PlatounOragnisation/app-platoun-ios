//
//  ProductCollectionViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 22/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ProductLikeCollectionViewCellDelegate: UIViewController {
    func afterLike(productId: String, isLiked: Bool)
}

class ProductLikeCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProductLikeCollectionViewCell"

    var product: ProductLiked?
    weak var parent: ProductLikeCollectionViewCellDelegate?
    var currentState: LikeState = .noLike
    @IBOutlet weak var borderLessContainer: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLoading: UIActivityIndicatorView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        borderLessContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemClick)))
        likeLoading.isHidden = true
    }
    
    func setup(product: ProductLiked, parent: ProductLikeCollectionViewCellDelegate) {
        self.product = product
        self.parent = parent
        
        titleLabel.text = product.title
        subtitleLabel.text = product.brandName
        productImageView.setImage(with: URL(string: product.pictureLink), placeholder: nil, options: .progressiveLoad)
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
            
            self.parent?.afterLike(productId: productId, isLiked: isLiked)
            (self.parent as? ContainerLikedProduct)?.updateLike()
        }
    }
    
    @objc func itemClick() {
        guard let product = self.product else { return }
        let vc = ProductViewController.instance(productId: product.id)
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}
