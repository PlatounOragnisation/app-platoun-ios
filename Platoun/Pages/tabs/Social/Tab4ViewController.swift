//
//  Tab4ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

class Tab4ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: FUIFirestoreTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let query = FirestoreUtils.getPostQuery()
        dataSource = FUIFirestoreTableViewDataSource(query: query, populateCell: { (tableView, indexPath, doc) -> UITableViewCell in
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: QuestionTableViewCell.identifier, for: indexPath) as? QuestionTableViewCell,
                let post = try? doc.data(as: Post.self) else {
                return UITableViewCell()
            }
            FirestoreUtils.getUserInfo(uid: post.createBy) { result in
                switch result {
                case .success((let name, let photo)):
                    cell.setup(post: post, userName: name, userPhoto: photo)
                case .failure(let error):
                    cell.setup(post: post, userName: "", userPhoto: nil)
                }
            }
            cell.delegate = self
            return cell
        })
    }
    
    var first = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if first {
            self.dataSource.bind(to: self.tableView)
            first = false
        }
    }
}

extension Tab4ViewController: QuestionTableViewCellDelegate {
    func displayComments(postId: String, focused: Bool) {
        let vc = CommentsViewController.instance(postId: postId, focussed: focused)
        self.present(vc, animated: true)
    }
    
    func displayActionMore(post: Post) {
        let alert = UIAlertController(title: nil, message: "Que souhaitez-vous faire ?", preferredStyle: .actionSheet)
        
        if post.createBy == Auth.auth().currentUser?.uid {
            alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: { _ in
                FirestoreUtils.deletePost(postId: post.postId)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Signaler", style: .destructive, handler: { _ in
                guard let currentUser = Auth.auth().currentUser else { return }
                FirestoreUtils.saveReport(post: post, userUid: currentUser.uid) { result in
                    switch result {
                    case .success():
                        UIKitUtils.showAlert(in: self, message: "Le signalement à été envoyé") {}
                    case .failure(_):
                        UIKitUtils.showAlert(in: self, message: "Une erreur est survenue merci de réessayer ultérieurement") {}
                    }
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
