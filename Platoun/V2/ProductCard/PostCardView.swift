//
//  PostCardView.swift
//  Platoun
//
//  Created by Flavian Mary on 17/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol PostCardViewDelegate {
    func getParentViewController() -> UIViewController
    func getBottomConstraint() -> NSLayoutConstraint?
    func sizeChange(isSmallVersion: Bool)
    func footerOnClick()
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

class PostCardView: NibView {
    
    var post: PostV2?
    var isSmallVersion: Bool = true
    var canChangeSize: Bool = true
    var delegate: PostCardViewDelegate?
    
    
    init(isSmallVersion: Bool, canChangeSize: Bool = true) {
        self.isSmallVersion = isSmallVersion
        self.canChangeSize = canChangeSize
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var moreContainerView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var seeMoreContainer: UIView!
    @IBOutlet weak var askQuestionContainer: UIView!
    
    override func setup() {
        self.view.clipsToBounds = true
        self.view.layer.cornerRadius = 25
        
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = 25
        
        moreContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionTapMore)))
        
        footerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionTapFooter)))
        
        updateSize(animate: false)
        
        self.applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    }
    
    func update(with post: PostV2) {
        self.post = post
        imageView.setImage(with: URL(string: post.imageFileURL)!, placeholder: nil, options: .progressiveLoad)
        if let image = URL(string: post.user.image) {
            userImageView.setImage(with: image, placeholder: nil, options: .progressiveLoad)
        } else {
            userImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
        userNameButton.setTitle("@\(post.user.name)", for: .normal)
        productNameLabel.text = post.name
        commentLabel.text = post.comment
    }
    
    func updateSize(animate: Bool) {
        self.askQuestionContainer.alpha = self.isSmallVersion ? 0 : 1
        self.askQuestionContainer.isHidden = self.isSmallVersion
        
        self.seeMoreContainer.alpha = self.isSmallVersion ? 1 : 0
        self.seeMoreContainer.isHidden = !self.isSmallVersion
        
        self.moreContainerView.isHidden = self.isSmallVersion

        
        self.shareButton.isHidden = !animate && self.isSmallVersion
        
        self.shareButton.alpha = self.isSmallVersion ? 0 : 1
        self.commentLabel.numberOfLines = self.isSmallVersion ? 1 : 0
        
        if let constrain = self.delegate?.getBottomConstraint() {
            constrain.constant = self.isSmallVersion ? -145 : -80
        }
    }
    
    func animateUpdateSize() {
        self.delegate?.sizeChange(isSmallVersion: self.isSmallVersion)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut]) {
            
            self.updateSize(animate: true)
            
            self.moreContainerView.superview?.layoutIfNeeded()
            self.commentLabel.superview?.layoutIfNeeded()
            self.commentLabel.superview?.superview?.layoutIfNeeded()
        } completion: { _ in
            self.shareButton.isHidden = self.isSmallVersion
        }
    }
    
    @objc func actionTapFooter() {
        self.delegate?.footerOnClick()
        guard self.canChangeSize else { return }
        self.isSmallVersion = !self.isSmallVersion
        self.animateUpdateSize()
    }
    
    @IBAction func actionTapShare() {
        guard let viewController = self.delegate?.getParentViewController(), let _ = self.post else { return }
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addRect(UIScreen.main.bounds)
            ctx.cgContext.drawPath(using: .fill)

            let rect = CGRect(
                x: (width - self.bounds.size.width) / 2 ,
                y: (height - self.bounds.size.height) / 2,
                width: self.bounds.size.width,
                height: self.bounds.size.height
            )
            
            self.drawHierarchy(in: rect, afterScreenUpdates: true)
        }
        
        let imageToShare:[Any] = [ image ]
        
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]

        // present the view controller
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func actionTapUserName() {
        guard let viewController = self.delegate?.getParentViewController(), let post = self.post else { return }
        let storyBoard = UIStoryboard(name: "V2", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfilV2ViewController")
        guard let destination = vc as? ProfilV2ViewController else { return }
        
        destination.userId = post.user.id
        viewController.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func actionTapMore() {
        guard let viewController = self.delegate?.getParentViewController(), let post = self.post else { return }

        let alert = UIAlertController(title: nil, message: "Que souhaitez-vous faire ?", preferredStyle: .alert)
        
        if post.user.id == Auth.auth().currentUser?.uid {
            alert.addAction(UIAlertAction(title: "Le Supprimer", style: .destructive, handler: { _ in
                
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Le Signaler", style: .destructive, handler: { _ in
                
            }))
        }
        alert.addAction(UIAlertAction(title: "Rien", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }
    
    @IBAction func actionTapSeeMore() {
        guard self.canChangeSize else { return }
        self.isSmallVersion = false
        self.animateUpdateSize()
    }
    
    @IBAction func actionTapAskQuestion() {
        guard let viewController = self.delegate?.getParentViewController(), let _ = self.post else { return }

        let vc = UIAlertController.getFeatureAvailableSoon()
        viewController.present(vc, animated: true)
    }
}
