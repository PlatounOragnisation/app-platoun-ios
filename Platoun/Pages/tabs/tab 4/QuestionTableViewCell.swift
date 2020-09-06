//
//  QuestionTableViewCell.swift
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

class QuestionTableViewCell: UITableViewCell {
    static let identifier = "PostCell"
    
    var post: Post?
    
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var postCategoryLabel: UILabel!
    @IBOutlet weak var textPostLabel: UILabel!
    @IBOutlet weak var imagesContainerStackView: UIStackView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var writeCommentButton: UIButton!
    
    func setup(post: Post, userName: String, userPhoto: URL?) {
        guard let user = Auth.auth().currentUser else { return }
        
        FirestoreUtils.getUserInfo(uid: post.createBy) { result in
            guard case let .success((name,photo)) = result else { return }
            self.creatorImageView.setImage(with: photo, placeholder: nil, options: .progressiveLoad)
            self.creatorNameLabel.text = name
        }
        
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
        self.textPostLabel.text = post.text
        
        self.commentsButton.setTitle("\(post.comments.count) Comments", for: .normal)
        self.upVoteButton.setTitle("\(post.votes.count) 🔥", for: .normal)
        
        self.currentUserImageView.setImage(with: user.photoURL, placeholder: nil, options: .progressiveLoad)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
    }
    
    @IBAction func commentsButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func upVoteButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func writeCommentButtonAction(_ sender: Any) {
        
    }
    
}
