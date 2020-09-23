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
import FirebaseCrashlytics

class Tab4ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sentenceTitleLabel: UILabel!
    @IBOutlet weak var filterAll: UIView!
    @IBOutlet weak var labelAll: UILabel!
    @IBOutlet weak var filterSugestion: FilterGradientView!
    @IBOutlet weak var dotSugestion: UIView!
    @IBOutlet weak var labelSugestion: UILabel!
    @IBOutlet weak var filterQuestion: FilterGradientView!
    @IBOutlet weak var dotQuestion: UIView!
    @IBOutlet weak var labelQuestion: UILabel!
    
    var dataSource: FUIFirestoreTableViewDataSource!
    var received: Date = Date()
    var posts: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        sentenceTitleLabel.text = "Help us find  the next Product/Brand you want on the app"
        labelAll.text = "All"
        labelSugestion.text = "Suggestions"
        labelQuestion.text = "Questions"
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
        
        let query = FirestoreUtils.getPostQuery()
//        self.requestBy(query: query)
        let time = Date()
        dataSource = FUIFirestoreTableViewDataSource(query: query, populateCell: { (tableView, indexPath, doc) -> UITableViewCell in
            let received = Date()
            print("received:\(received.timeIntervalSince1970-time.timeIntervalSince1970)")
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell,
                let post = try? doc.data(as: Post.self) else {
                return UITableViewCell()
            }
            cell.setup(post: post)
            cell.delegate = self
            return cell
        })
        dataSource.queryErrorHandler = { error in
            print(error)
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.view.applyGradient(colours: [ThemeColor.BackgroundGradientCircle1, ThemeColor.BackgroundGradientCircle2])
        
        self.filterAll.applyGradient(colours: [ThemeColor.BackgroundGradient2, ThemeColor.BackgroundGradient1])
        self.filterAll.layer.cornerRadius = 12
        self.filterAll.layer.masksToBounds = true
        
        self.dotSugestion.applyGradient(colours: [ThemeColor.Suggestion2, ThemeColor.Suggestion1])
        self.dotSugestion.layer.cornerRadius = 5
        self.dotSugestion.layer.masksToBounds = true
        
        self.dotQuestion.applyGradient(colours: [ThemeColor.Question2, ThemeColor.Question1])
        self.dotQuestion.layer.cornerRadius = 5
        self.dotQuestion.layer.masksToBounds = true
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
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

extension Tab4ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? PostTableViewCell)?.cancelLoadPost()
    }
}
