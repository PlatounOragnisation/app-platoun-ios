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

class SocialViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sentenceTitleLabel: UILabel!
    @IBOutlet weak var filterAll: FilterGradientView!
    @IBOutlet weak var labelAll: UILabel!
    @IBOutlet weak var filterSugestion: FilterGradientView!
    @IBOutlet weak var labelSugestion: UILabel!
    @IBOutlet weak var filterQuestion: FilterGradientView!
    @IBOutlet weak var labelQuestion: UILabel!
    
    var dataSource: FUIFirestoreTableViewDataSource?
    var received: Date = Date()
    var posts: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        sentenceTitleLabel.text = "Help us find the next Product/Brand you want on the app"
        labelAll.text = "Tout voir"
        filterAll.labelConnected = labelAll
        labelSugestion.text = "Suggestions"
        filterSugestion.labelConnected = labelSugestion
        labelQuestion.text = "Questions"
        filterQuestion.labelConnected = labelQuestion
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
        
        let query = FirestoreUtils.getPostQuery()
        self.dataSource = FUIFirestoreTableViewDataSource(query: query, populateCell: { (tableView, indexPath, doc) -> UITableViewCell in
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell,
                let post = try? doc.data(as: Post.self) else {
                return UITableViewCell()
            }
            cell.setup(post: post)
            cell.delegate = self
            return cell
        })
        self.dataSource?.queryErrorHandler = { error in
            print(error)
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.view.applyGradient(colours: [ThemeColor.BackgroundGradientCircle1, ThemeColor.BackgroundGradientCircle2])
        
        self.filterAll.set(isSelected: true)
        self.filterQuestion.set(isSelected: false)
        self.filterSugestion.set(isSelected: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    var first = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if first {
            self.dataSource?.bind(to: self.tableView)
            first = false
        }
    }
    
    func selectAll() {
        if !filterAll.isSelected {
            self.dataSource?.query = FirestoreUtils.getPostQuery()
        }
        self.filterAll.set(isSelected: true)
        self.filterQuestion.set(isSelected: false)
        self.filterSugestion.set(isSelected: false)
    }
    
    func selectSuggestion() {
        if !filterSugestion.isSelected {
            self.dataSource?.query = FirestoreUtils.getPostQuery(filter: .suggestion)
        }
        self.filterAll.set(isSelected: false)
        self.filterQuestion.set(isSelected: false)
        self.filterSugestion.set(isSelected: true)
    }
    
    func selectQuestion() {
        if !filterQuestion.isSelected {
            self.dataSource?.query = FirestoreUtils.getPostQuery(filter: .question)
        }
        self.filterAll.set(isSelected: false)
        self.filterQuestion.set(isSelected: true)
        self.filterSugestion.set(isSelected: false)
    }
    
    @IBAction func actionTapAllFilter(_ sender: Any) {
        self.selectAll()
    }
    
    @IBAction func actionTapQuestionFilter(_ sender: Any) {
        let obj: (Bool, Bool, Bool) = (self.filterAll.isSelected, self.filterQuestion.isSelected, self.filterSugestion.isSelected)
        switch obj {
        case (true, true, true): selectSuggestion()
        case (true, true, false): selectAll()
        case (true, false, true): selectQuestion()
        case (true, false, false): selectQuestion()

        case (false, false, false): selectQuestion()
        case (false, true, false): selectAll()
        case (false, false, true): selectQuestion()
        case (false, true, true): selectSuggestion()
        }
    }
    
    @IBAction func actionTapSuggestionFilter(_ sender: Any) {
        let obj: (Bool, Bool, Bool) = (self.filterAll.isSelected, self.filterQuestion.isSelected, self.filterSugestion.isSelected)
        switch obj {
        case (true, true, true): selectQuestion()
        case (true, true, false): selectSuggestion()
        case (true, false, true): selectAll()
        case (true, false, false): selectSuggestion()

        case (false, false, false): selectSuggestion()
        case (false, true, false): selectSuggestion()
        case (false, false, true): selectAll()
        case (false, true, true): selectQuestion()
        }
    }
}

extension SocialViewController: QuestionTableViewCellDelegate {
    func displayComments(postId: String, postCreatorId: String, postCreator: String? ,focused: Bool) {
        let vc = CommentsViewController.instance(postId: postId, postCreatorId: postCreatorId, postCreator: postCreator, focussed: focused)
        self.present(vc, animated: true)
    }
    
    func displayActionMore(post: Post) {
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
}

extension SocialViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? PostTableViewCell)?.cancelLoadPost()
    }
}
