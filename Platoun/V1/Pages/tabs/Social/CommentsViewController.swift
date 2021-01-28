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
    
    static func instance(postId: String, postCreatorId: String, postCreator: String?, focussed: Bool)-> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard
            .instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
//        let vc = nav.viewControllers.first as! CommentsViewController
        vc.postId = postId
        vc.postCreator = postCreator
        vc.postCreatorId = postCreatorId
        vc.focussed = focussed
        return vc
    }

    var postId: String!
    var postCreatorId: String!
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
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var addAttachment: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
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
        self.textField.enablesReturnKeyAutomatically = true
        
        self.titleLabel.text = "Réponses\(postCreator != nil ? " @\(postCreator!)" : "")"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        
        self.textField.delegate = self
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(doubleTappedFirstImageView))
        tap1.numberOfTapsRequired = 2
        self.firstImageView.isUserInteractionEnabled = true
        self.firstImageView.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(doubleTappedSecondImageView))
        tap2.numberOfTapsRequired = 2
        self.secondImageView.isUserInteractionEnabled = true
        self.secondImageView.addGestureRecognizer(tap2)
    }
    
    @objc func doubleTappedFirstImageView() {
        
        if self.secondImageView.image != nil {
            self.firstImageView.image = self.secondImageView.image
            self.secondImageView.image = nil
            self.secondImageView.isHidden = true
        } else {
            self.firstImageView.isHidden = true
            self.firstImageView.image = nil
        }
        
        self.updateAddAttachment()
        self.updateSendButtonVisibility(text: self.textField.text)
    }
    
    @objc func doubleTappedSecondImageView() {
        
        self.secondImageView.isHidden = true
        self.secondImageView.image = nil

        
        self.updateAddAttachment()
        self.updateSendButtonVisibility(text: self.textField.text)
    }
    
    func updateAddAttachment() {
        self.addAttachment.isHidden = self.firstImageView.image != nil && self.secondImageView.image != nil
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
                    self.bottomConstraint.constant = 8
                } else {
                    self.bottomConstraint.constant = (endFrame?.size.height ?? 0.0) - self.view.safeAreaInsets.bottom + 8
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
    
    @IBAction func sendButtonAction(_ sender: Any) {
        self.textField.resignFirstResponder()
        self.sendAction() {
            self.updateAddAttachment()
            self.updateSendButtonVisibility(text: nil)
            self.loader.stopAnimating()
        }
    }
    
    func updateSendButtonVisibility(text: String?) {
        let text = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sendButtonIsHidden = self.firstImageView.image == nil && self.secondImageView.image == nil && text.isEmpty
        
        guard self.sendButton.isHidden != sendButtonIsHidden else { return }
        
        self.sendButton.alpha = self.sendButton.isHidden ? 0.0 : 1.0
        self.sendButton.isHidden = sendButtonIsHidden
        UIView.animate(withDuration: 0.2) {
            self.sendButton.alpha = self.sendButton.isHidden ? 0.0 : 1.0
        }
    }
    
    
    func sendAction(completion: @escaping ()->Void) {
        self.loader.isHidden = false
        self.sendButton.isHidden = true
        self.loader.startAnimating()
        guard let currentUser = Auth.auth().currentUser else { return }
        let commentId = "\(currentUser.uid)-\(UUID().uuidString)"
        
        let text = (self.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty || self.firstImageView.image != nil || self.secondImageView.image != nil else {
            UIKitUtils.showAlert(in: self, message: "Le commentaire ne peut pas être vide") {
                completion()
            }
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
                        self.sendNotifComment(at: self.postCreatorId)
                        completion()
                    } else {
                        StorageUtils.deleteImageFor(userId: currentUser.uid, commentId: commentId, numberOfImages: listImage.count)
                        UIKitUtils.showAlert(in: self, message: "Un problème est survenue lors de l'envoie du commentaire.") {completion()}
                    }
                }
            case .failure(_):
                completion()
                break
            }
        }
    }
    
    func sendNotifComment(at userId: String) {
        guard Auth.auth().currentUser?.uid != userId else { return }
        let notification = CommentPlatounNotification(postId: self.postId)
        
        FirestoreUtils.Users.getUserNotif(uid: userId) { token in
            FirestoreUtils.Notifications.saveCommentNotification(userId: userId, notif: notification) {
                if case .success = $0 {
                    guard let token = token else { return }
                    NotificationUtils.sendCommentNotif(fcmToken: token, notif: notification)
                }
            }
        }
    }
}

extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (self.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        self.textField.resignFirstResponder()
        self.sendAction() {
            self.updateAddAttachment()
            self.updateSendButtonVisibility(text: nil)
            self.loader.stopAnimating()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: textRange, with: string)

        self.updateSendButtonVisibility(text: updatedText)
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
        self.updateSendButtonVisibility(text: self.textField.text)
        self.updateAddAttachment()
    }
}


extension CommentsViewController: UITableViewDelegate {
    
}
