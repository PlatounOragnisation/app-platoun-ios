//
//  ContributeViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ContributeViewController: UIViewController {
    
    static func getInstance() -> ContributeViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContributeViewController") as! ContributeViewController
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstAddImageView: AddImageView!
    @IBOutlet weak var secondAddImageView: AddImageView!
    
    @IBOutlet weak var categoryDropDown: DropDownPostView!
    @IBOutlet weak var languageDropDown: DropDownPostView!
    
    @IBOutlet weak var textTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareLoading: UIActivityIndicatorView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        
        self.shareLoading.isHidden = true
        self.titleLabel.text = "Contribuer"
        self.placeholderLabel.text = "Un produit t’intéresse et n’est pas encore sur l’app ?\nTu peux nous faire une suggestion afin que l’on puisse l’ajouter !"
        self.shareButton.setTitle("Partager", for: .normal)
        self.titleLabel.applyGradientWith(startColor: ThemeColor.BackgroundGradient1, endColor: ThemeColor.BackgroundGradient2)
        
        self.categoryDropDown.items = Post.PostType.allCases.map { $0.rawValue }
        self.languageDropDown.items = Post.LanguageType.allCases.map { $0.rawValue }
        
        self.textTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.shareButton.applyGradient(colours: [ThemeColor.BackgroundGradient2, ThemeColor.BackgroundGradient1])
        self.shareButton.layer.cornerRadius = self.shareButton.frame.size.height/2
        self.shareButton.layer.masksToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
        
    @IBAction func shareButtonAction(_ sender: Any) {
        guard Auth.auth().currentUser != nil else { return }
        guard let text = textTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            UIKitUtils.showAlert(in: self, message: "Le Texte ne peut pas être vide", completion: {}); return
        }
        
        
        UIKitUtils.showAlert(
            in: self,
            message: "Êtes vous sur de vouloir publier ce post ?",
            action1Title: "Oui", completionOK: { self.publishPost(text: text) },
            action2Title: "Non", completionCancel: {})
    }
    
    func publishPost(text: String) {
        self.shareLoading.startAnimating()
        self.shareButton.isHidden = true
        let user = Auth.auth().currentUser!
        let date = Date()
        let postId = "\(user.uid)-\(date.timeIntervalSince1970)"
        
        let category = Post.PostType(rawValue: self.categoryDropDown.getItemSelected()) ??
            Post.PostType.suggestion
        
        let language = Post.LanguageType(rawValue: self.languageDropDown.getItemSelected()) ??
            Post.LanguageType.french
        
        self.uploadImages(postId: postId, images: getImages()) { urls in
            let post = Post.create(
                by: user.uid,
                for: postId,
                authorName: user.displayName,
                authorPhoto: user.photoURL?.absoluteString,
                text: text,
                images: urls,
                category: category,
                language: language,
                createAt: date)
            
            FirestoreUtils.Posts.savePost(post: post) { result in
                switch result {
                case .success():
                    UIKitUtils.showAlert(in: self, message: "Votre post a été publié") {
                        self.tabBarController?.selectedIndex = 3
                        self.tabBarController?.viewControllers?[2] = ContributeViewController.getInstance()
                    }
                case .failure(let error):
                    StorageUtils.deleteImageFor(userId: user.uid, postId: postId, numberOfImages: urls.count)
                    UIKitUtils.showAlert(in: self, message: "Une erreur est survenue: \(error.localizedDescription)"){
                        self.shareLoading.stopAnimating()
                        self.shareButton.isHidden = false
                    }
                }
            }
        }
        
    }
    
    private func uploadImages(postId: String, images: [UIImage], completion: @escaping ([String])->Void) {
        let user = Auth.auth().currentUser!
        
        guard images.count > 0 else { completion([]); return }
        
        StorageUtils.uploadImagePost(image: images[0], userId: user.uid, postId: postId, imageCount: 0) { result in
            switch result {
            case .success(let imageUrl1):
                guard images.count > 1 else {
                    completion([imageUrl1]); return
                }
                StorageUtils.uploadImagePost(image: images[1], userId: user.uid, postId: postId, imageCount: 1) { result in
                    switch result {
                    case .success(let imageUrl2):
                        completion([imageUrl1, imageUrl2])
                    case .failure(let error):
                        StorageUtils.deleteImageFor(userId: user.uid, postId: postId, numberOfImages: 1)
                        UIKitUtils.showAlert(in: self, message: "Une erreur c'est produite lors de l'upload de la deuxième image: \n\(error.localizedDescription)") {}; return
                    }
                }
            case .failure(let error):
                UIKitUtils.showAlert(in: self, message: "Une erreur c'est produite lors de l'upload de la première image: \n\(error.localizedDescription)") {}; return
            }
        }
    }
    
    private func getImages() -> [UIImage] {
        return [self.firstAddImageView, self.secondAddImageView].compactMap { $0?.image }
    }
}

extension ContributeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let string = textView.text, let textRange = Range(range, in: string) else { return false }
        let updatedText = string.replacingCharacters(in: textRange, with: text)
        if updatedText.last == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if updatedText.contains("\n") {
            let te = updatedText.replacingOccurrences(of: "\n", with: "")
            textView.text = te
            return false
        }
        return true
    }
        
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.placeholderLabel.isHidden = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let text = (textView.text ?? "")
        if text.isEmpty {
            self.placeholderLabel.isHidden = false
        }
        return true
    }
}

extension ContributeViewController {
    @objc func keyboardNotification(notification: NSNotification) {
            if let userInfo = notification.userInfo {
                let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let endFrameY = endFrame?.origin.y ?? 0
                let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                
                let height: CGFloat
                if endFrameY >= UIScreen.main.bounds.size.height {
                    height = 0.0
                } else {
                    height = (endFrame?.size.height ?? 0.0) - ( self.tabBarController?.tabBar.frame.size.height ?? self.view.safeAreaInsets.bottom)
                }
                self.bottomConstraint.constant = -height
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: { self.view.layoutIfNeeded() },
                               completion: nil
                )
            }
        }
}
