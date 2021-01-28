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
    func displayComments(postId: String, postCreatorId: String, postCreator: String?, focused: Bool)
    func displayActionMore(post: Post)
}

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostCell"
    
    var post: Post?
    var delegate: QuestionTableViewCellDelegate?
    
    @IBOutlet weak var cellBackgroundView: DrawBackgroundView!
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var postCategoryLabel: UILabel!
    @IBOutlet weak var textViewPostLabel: UITextView!
    @IBOutlet weak var imagesContainerStackView: UIStackView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var upVoteView: UIStackView!
    @IBOutlet weak var upVoteLabel: UILabel!
    
    func setup(post: Post) {
        self.post = post
        self.cancelLoadPost()
        
        if let value = post.authorPhoto, let url = URL(string: value) {
            self.creatorImageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.creatorImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
        self.creatorNameLabel.text = post.authorName ?? "No Name"
        
        self.imagesContainerStackView.isHidden = post.images.count == 0
        self.firstImageView.isHidden = post.images.count < 1
        self.secondImageView.isHidden = post.images.count < 2

        if post.images.count > 0 {
            let ref: StorageReference = Storage.storage().reference(forURL: post.images[0])
            self.firstImageView.setImage(with: ref, placeholder: nil, options: .progressiveLoad)
        }
        if post.images.count > 1 {
            let ref: StorageReference = Storage.storage().reference(forURL: post.images[1])
            self.secondImageView.setImage(with: ref, placeholder: nil, options: .progressiveLoad)
        }
        
        self.postCategoryLabel.text = post.category.rawValue
        self.textViewPostLabel.text = post.text
        
        let commentCount = post.commentsCount
        
        let titleButton: String
        switch commentCount {
        case 0: titleButton = "Commentaire"
        case 1: titleButton = "1 Commentaire"
        default: titleButton = "\(commentCount) Commentaires"
        }        
        self.commentsButton.setTitle(titleButton, for: .normal)
        
        let votesCount = post.votes.count
        
        if let userId = Auth.auth().currentUser?.uid, post.votes.contains(where: {$0.userId == userId}){
            self.upVoteLabel.text = "\(votesCount) vote\(votesCount > 1 ? "s" : "")"
        } else {
            self.upVoteLabel.text = "Je vote"
        }
        
        self.upVoteView.isUserInteractionEnabled = true
        self.upVoteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.upVoteButtonAction)))
        self.cellBackgroundView.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.creatorImageView.layer.cornerRadius = self.creatorImageView.frame.height/2
    }

    func cancelLoadPost() {
        self.creatorImageView.sd_cancelCurrentImageLoad()
        self.firstImageView.sd_cancelCurrentImageLoad()
        self.secondImageView.sd_cancelCurrentImageLoad()
        self.firstImageView.image = nil
        self.secondImageView.image = nil
        self.creatorImageView.image = nil
    }
    
    @IBAction func moreAction(_ sender: Any) {
        guard let post = self.post else { return }
        delegate?.displayActionMore(post: post)
    }
    
    @IBAction func commentsButtonAction(_ sender: Any) {
        guard let post = self.post else { return }
        delegate?.displayComments(postId: post.postId, postCreatorId: post.createBy, postCreator: post.authorName, focused: false)
    }
    
    @objc func upVoteButtonAction() {
        guard let post = self.post, let currentUser = Auth.auth().currentUser else { return }
        FirestoreUtils.Posts.toogleVote(postId: post.postId, userUid: currentUser.uid)
    }
    
    func writeCommentAction() {
        guard let post = self.post else { return }
        delegate?.displayComments(postId: post.postId, postCreatorId: post.createBy, postCreator: post.authorName, focused: true)
    }
    
}
