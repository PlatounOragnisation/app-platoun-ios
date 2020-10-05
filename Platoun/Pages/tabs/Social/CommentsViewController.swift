//
//  CommentsViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 18/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics
import CropViewController

class CommentsViewController: UIViewController {
    
    static func instance(postId: String, postCreator: String?, focussed: Bool)-> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard
            .instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
//        let vc = nav.viewControllers.first as! CommentsViewController
        vc.postId = postId
        vc.postCreator = postCreator
        vc.focussed = focussed
        vc.modalPresentationStyle = .popover
        return vc
    }

    var postId: String!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var backgroundTextFieldView: UIView!
    var postCreator: String?
    var focussed: Bool = false
    var comments: [Comment] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var addAttachment: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url = Auth.auth().currentUser?.photoURL {
            self.currentUserImageView.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_social_default_profil"), options: .progressiveLoad)
        } else {
            self.currentUserImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
        self.reload()
        if focussed {
            self.textField.becomeFirstResponder()
            self.focussed = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstImageView.isHidden = true
        secondImageView.isHidden = true
        
        self.titleLabel.text = "Réponses\(postCreator != nil ? " @\(postCreator!)" : "")"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        
        self.textField.delegate = self
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
            if let userInfo = notification.userInfo {
                let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let endFrameY = endFrame?.origin.y ?? 0
                let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                if endFrameY >= UIScreen.main.bounds.size.height {
                    self.bottomConstraint.constant = 0.0
                } else {
                    self.bottomConstraint.constant = -((endFrame?.size.height ?? 0.0) - self.view.safeAreaInsets.bottom + 8)
                }
//                self.theTableView.scrollToBottomRow()
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: { self.view.layoutIfNeeded() },
                               completion: nil
                )
            }
        }
    
    func reload() {
        FirestoreUtils.Comments.getComments(postId: postId) { result in
            switch result {
            case .success(let comments):
                self.comments = comments.sorted(by: { (lhs, rhs) -> Bool in
                    return lhs.createdAt > rhs.createdAt
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                UIKitUtils.showAlert(in: self, message: "Une erreur est survenue: \(error.localizedDescription)") {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func actionAddAttachment(_ sender: Any) {
        guard self.firstImageView.image == nil || self.secondImageView.image == nil else { return }
        ImagePickerManager().pickImage(self) { image in
            self.crop(image: image)
        }
    }
    
    func crop(image: UIImage) {
        let cropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetButtonHidden = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: cropViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    func uploadImage(userId: String, commentId: String, list: [String], imageView: UIImageView, completion: @escaping (Result<[String], Error>)->Void){
        let isFirst = imageView == self.firstImageView
        
        if let image = imageView.image {
            StorageUtils.uploadImageComment(image: image, userId: userId, commentId: commentId, imageCount: isFirst ? 0 : 1) { (result) in
                switch result {
                case .success(let url):
                    if isFirst {
                        self.uploadImage(userId: userId, commentId: commentId, list: [url], imageView: self.secondImageView, completion: completion)
                    } else {
                        completion(.success(list+[url]))
                    }
                case .failure(let error):
                    if !isFirst {
                        StorageUtils.deleteImageFor(userId: userId, commentId: commentId, numberOfImages: list.count)
                    }
                    completion(.failure(error))
                }
            }
        } else {
            if isFirst {
                self.uploadImage(userId: userId, commentId: commentId, list: [], imageView: self.secondImageView, completion: completion)
            } else {
                completion(.success(list))
            }
        }
        
    }
    
    func sendAction() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let commentId = "\(currentUser.uid)-\(UUID().uuidString)"
        guard let text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            UIKitUtils.showAlert(in: self, message: "Le commentaire ne peut pas être vide") {}
            return
        }
        
        self.uploadImage(userId: currentUser.uid, commentId: commentId, list: [], imageView: self.firstImageView) { result in
            
            switch result {
            case .success(let listImage):
                let comment = Comment(id: commentId, text: text, images: listImage, createdAt: Date(), createBy: currentUser.uid, authorName: currentUser.displayName, authorPhoto: currentUser.photoURL?.absoluteString)
                FirestoreUtils.Comments.addComment(postId: self.postId, comment: comment) { success in
                    if success {
                        self.reload()
                        self.textField.text = ""
                        self.firstImageView.image = nil
                        self.firstImageView.isHidden = true
                        self.secondImageView.image = nil
                        self.secondImageView.isHidden = true
                        self.addAttachment.isHidden = false
                    } else {
                        StorageUtils.deleteImageFor(userId: currentUser.uid, commentId: commentId, numberOfImages: listImage.count)
                        UIKitUtils.showAlert(in: self, message: "Un problème est survenue lors de l'envoie du commentaire.") {}
                    }
                }
            case .failure(_):
                break
            }
        }
    }
}

extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        self.sendAction()
        return true
    }
}

extension CommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:  CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(comment: self.comments[indexPath.row])
        return cell
    }
}

extension CommentsViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)

        if self.firstImageView.image == nil {
            self.firstImageView.isHidden = false
            self.firstImageView.image = image
        } else if self.secondImageView.image == nil {
            self.secondImageView.isHidden = false
            self.secondImageView.image = image
        }
        self.addAttachment.isHidden = self.firstImageView.image != nil && self.secondImageView.image != nil
    }
}


extension CommentsViewController: UITableViewDelegate {
    
}
