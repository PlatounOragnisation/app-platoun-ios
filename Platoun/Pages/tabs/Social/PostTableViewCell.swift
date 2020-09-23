//
//  PostTableViewCell.swift
//  Platoun
//
//  Created by Flavian Mary on 06/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseStorage
import FirebaseCrashlytics

protocol QuestionTableViewCellDelegate {
    func displayComments(postId: String, focused: Bool)
    func displayActionMore(post: Post)
}

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostCell"
    
    var post: Post?
    var delegate: QuestionTableViewCellDelegate?
    
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var postCategoryLabel: UILabel!
    @IBOutlet weak var textPostLabel: UILabel!
    @IBOutlet weak var imagesContainerStackView: UIStackView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var upVoteView: UIStackView!
    @IBOutlet weak var upVoteLabel: UILabel!
    
    func setupUserInfo(userName: String, userPhoto: URL?) {
        self.cancelLoadUser()
        if let url = userPhoto {
            self.creatorImageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.creatorImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
        
        self.creatorNameLabel.text = userName
    }
    
    func setup(post: Post) {
        self.post = post
        self.cancelLoadPost()
        
        self.imagesContainerStackView.isHidden = post.images.count == 0
        self.firstImageView.isHidden = post.images.count < 1
        self.secondImageView.isHidden = post.images.count < 2

        if post.images.count > 0 {
            let ref: StorageReference = Storage.storage().reference(forURL: post.images[0])
//            self.firstImageView.setImage(with: ref, placeholder: nil, options: .progressiveLoad)
        }
        if post.images.count > 1 {
            let ref: StorageReference = Storage.storage().reference(forURL: post.images[1])
//            self.secondImageView.setImage(with: ref, placeholder: nil, options: .progressiveLoad)
        }
        
        self.postCategoryLabel.text = post.category.rawValue
        self.textPostLabel.text = post.text
        
        let commentCount = post.comments.count
        
        let titleButton: String
        switch commentCount {
        case 0: titleButton = "Commentaire"
        case 1: titleButton = "1 Commentaire"
        default: titleButton = "\(commentCount) Commentaires"
        }        
        self.commentsButton.setTitle(titleButton, for: .normal)
        
        let votesCount = post.votes.count
        self.upVoteLabel.text = votesCount == 0 ? "Upvote" : "\(votesCount) Upvote"
        
        self.upVoteView.isUserInteractionEnabled = true
        self.upVoteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.upVoteButtonAction)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.creatorImageView.layer.cornerRadius = self.creatorImageView.frame.height/2
//        self.initializeBackground()
    }
    
    func cancelLoadUser() {
        self.creatorImageView.sd_cancelCurrentImageLoad()
        self.creatorImageView.image = nil
    }
    

    func cancelLoadPost() {
        self.firstImageView.sd_cancelCurrentImageLoad()
        self.secondImageView.sd_cancelCurrentImageLoad()
        self.firstImageView.image = nil
        self.secondImageView.image = nil
    }
    
   
    lazy var shadows = UIView()
    var shadowPath0: UIBezierPath?
    var shapes = UIView()
    var layer0 = CALayer()

    let layer1 = CAGradientLayer()
    
    func initializeBackground() {
        self.contentView.backgroundColor = .clear
        let frame = CGRect(x: 16, y: 16, width: UIScreen.main.bounds.width-32, height: self.contentView.frame.height-32)
        let frameZero = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-32, height: self.contentView.frame.height-32)

        shadows.clipsToBounds = false
        shadows.frame = frameZero

        if !self.contentView.subviews.contains(shadows) {
            self.contentView.insertSubview(shadows, at: 0)
        }


        shadowPath0 = UIBezierPath(roundedRect: frame, cornerRadius: 25)

        layer0.shadowPath = shadowPath0!.cgPath

        layer0.shadowColor = ThemeColor.DrakGrey.withAlphaComponent(0.25).cgColor

        layer0.shadowOpacity = 1

        layer0.shadowRadius = 14

        layer0.shadowOffset = CGSize(width: 0, height: 1)

        layer0.bounds = shadows.bounds

        layer0.position = shadows.center

        if !(shadows.layer.sublayers?.contains(layer0) ?? false) {
            shadows.layer.addSublayer(layer0)
        }

        shapes.frame = frame

        shapes.clipsToBounds = true

        if !self.contentView.subviews.contains(shapes) {
            self.contentView.insertSubview(shapes, at: 1)
        }


        layer1.colors = [ThemeColor.White.cgColor, ThemeColor.F7F6FB.cgColor]

        layer1.locations = [0, 1]

        layer1.startPoint = CGPoint(x: 0.25, y: 0.5)

        layer1.endPoint = CGPoint(x: 0.75, y: 0.5)

        layer1.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.94, b: -0.91, c: 0.91, d: 1, tx: -0.45, ty: 0.46))

        layer1.bounds = shapes.bounds.insetBy(dx: -0.5*shapes.bounds.size.width, dy: -0.5*shapes.bounds.size.height)

        layer1.position = shapes.center

        if !(shapes.layer.sublayers?.contains(layer1) ?? false) {
            shapes.layer.addSublayer(layer1)
        }

        shapes.layer.cornerRadius = 25
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func moreAction(_ sender: Any) {
        guard let post = self.post else { return }
        delegate?.displayActionMore(post: post)
    }
    
    @IBAction func commentsButtonAction(_ sender: Any) {
        guard let post = self.post else { return }
        delegate?.displayComments(postId: post.postId, focused: false)
    }
    
    @objc func upVoteButtonAction() {
        guard let post = self.post, let currentUser = Auth.auth().currentUser else { return }
        FirestoreUtils.toogleVote(postId: post.postId, userUid: currentUser.uid)
    }
    
    func writeCommentAction() {
        guard let post = self.post else { return }
        delegate?.displayComments(postId: post.postId, focused: true)
    }
    
}
