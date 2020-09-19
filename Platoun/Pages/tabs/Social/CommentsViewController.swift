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

class CommentsViewController: UIViewController {
    
    static func instance(postId: String, focussed: Bool)-> CommentsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard
            .instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        vc.postId = postId
        vc.focussed = focussed
        vc.modalPresentationStyle = .popover
        return vc
    }

    var postId: String!
    var focussed: Bool = false
    var comments: [Post.Comment] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reload()
        if focussed {
            self.textField.becomeFirstResponder()
            self.focussed = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    self.bottomConstraint.constant = -(endFrame?.size.height ?? 0.0)
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
        FirestoreUtils.getPost(postId: postId) { result in
            switch result {
            case .success(let post):
                self.comments = post.comments.sorted(by: { (lhs, rhs) -> Bool in
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

    
    @IBAction func sendAction(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            UIKitUtils.showAlert(in: self, message: "Le commentaire ne peut pas être vide") {}
            return
        }
        
        let comment = Post.Comment(text: text, images: [], createdAt: Date(), userId: currentUser.uid)
        
        FirestoreUtils.addComment(postId: self.postId, comment: comment) { success in
            if success {
                self.reload()
                self.textField.text = ""
            } else {
                UIKitUtils.showAlert(in: self, message: "Un problème est survenue lors de l'envoie du commentaire.") {}
            }
        }
        
        
    }
}

extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return true
    }
}

extension CommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) else {
//            return UITableViewCell()
//        }
        
        cell.textLabel?.text = self.comments[indexPath.row].text
        return cell
    }
}

extension CommentsViewController: UITableViewDelegate {
    
}
