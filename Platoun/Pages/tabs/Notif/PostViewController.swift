//
//  PostViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 18/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseStorage
import FirebaseCrashlytics

class PostViewController: UIViewController {
    
    static func getInstance(post: Post) -> PostViewController{
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        vc.post = post
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    static func getInstance(notification: CommentPlatounNotification) -> PostViewController{
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        vc.notification = notification
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    var post: Post?
    var notification: CommentPlatounNotification?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var cellBackgroundView: DrawBackgroundView!
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
    
    
    func setup(post: Post) {
        self.containerView.isHidden = false
        self.loader.stopAnimating()
        
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
        self.textPostLabel.text = post.text
        
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
        self.creatorImageView.layer.cornerRadius = self.creatorImageView.frame.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let post = self.post {
            self.setup(post: post)
        } else if let notif = self.notification{
            self.loader.isHidden = false
            self.containerView.isHidden = true
            self.loader.startAnimating()
            self.getPost(notification: notif)
        } else {
            UIKitUtils.showAlert(in: self, message: "Une erreur c'est produite") {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var listener: ListenerRegistration?
    
    func getPost(notification: CommentPlatounNotification) {
        listener = FirestoreUtils.Posts
            .getPost(postId: notification.postId) { post in
                self.post = post
                self.setup(post: post)
            }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }
    @IBAction func pressOutsidePostAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func moreAction(_ sender: Any) {
        guard let post = self.post else { return }
        let alert = UIAlertController(title: nil, message: "Que souhaitez-vous faire ?", preferredStyle: .actionSheet)
        
        if post.createBy == Auth.auth().currentUser?.uid {
            alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: { _ in
                FirestoreUtils.Posts.deletePost(postId: post.postId)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Signaler", style: .destructive, handler: { _ in
                guard let currentUser = Auth.auth().currentUser else { return }
                FirestoreUtils.Reports.saveReport(post: post, userUid: currentUser.uid) { result in
                    switch result {
                    case .success():
                        UIKitUtils.showAlert(in: self, message: "Le signalement a été envoyé") {}
                    case .failure(_):
                        UIKitUtils.showAlert(in: self, message: "Une erreur est survenue merci de réessayer ultérieurement") {}
                    }
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func commentsButtonAction(_ sender: Any) {
        guard let post = self.post else { return }
        let vc = CommentsViewController.instance(postId: post.postId, postCreatorId: post.createBy, postCreator: post.authorName, focussed: false)
        self.present(vc, animated: true)
    }
    
    @objc func upVoteButtonAction() {
        guard let post = self.post, let currentUser = Auth.auth().currentUser else { return }
        FirestoreUtils.Posts.toogleVote(postId: post.postId, userUid: currentUser.uid)
    }
}

class BackgroundPostView: UIView, IDrawGradientView {
    var startColor: UIColor = ThemeColor.BackgroundGradient1
    
    var endColor: UIColor = ThemeColor.BackgroundGradient2
    
    var startPointX: CGFloat = 0
    
    var startPointY: CGFloat = -1
    
    var endPointX: CGFloat = -1
    
    var endPointY: CGFloat = 0
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        self.drawGradient(context: context)
    }
}
