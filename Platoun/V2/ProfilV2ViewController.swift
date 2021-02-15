//
//  ProfilV2ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 06/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfilV2ViewController: UIViewController {
    
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var suggestionCountLabel: UILabel!
    @IBOutlet weak var suggestionTitleLabel: UILabel!
    
    @IBOutlet weak var votesCountLabel: StyleLabel!
    @IBOutlet weak var votesTitleLabel: StyleLabel!
    
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var suggestionLine: UIImageView!
    @IBOutlet weak var swipeStarLabel: UILabel!
    @IBOutlet weak var swipeStarLine: UIImageView!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var votesLine: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.initPlatounTheme(isTransparent: true)
        self.navigationItem.initTitleItem()

        profilImageView.layer.cornerRadius = 16
        profilImageView.layer.masksToBounds = true
        
        votesCountLabel.update(colors: [ThemeColor.cFFE600, ThemeColor.cFFC7C7])
        votesTitleLabel.update(colors: [ThemeColor.cFFE600, ThemeColor.cFFC7C7])
        
        UserService.shared.getUser(userId: self.userId) { user in
            guard let user = user else { return }
            self.user = user
            self.initializeUser()
        }
        
        self.sugestionActionTap("")
    }
    
    private var user: UserV2!
    private var posts: [ProductVote] = []
    
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func initializeUser() {
        userNameLabel.text = "@\(user.name ?? "Anonyme")"
        suggestionCountLabel.text = user.suggestionCount.concat()
        suggestionTitleLabel.text = user.suggestionCount > 1 ? "suggestions" : "suggestion"
        votesCountLabel.text = user.point.concat()
        votesTitleLabel.text = user.point > 1 ? "votes" : "vote"
        
        if let profilPicture = user.imageProfilURL {
            profilImageView.setImage(with: URL(string: profilPicture)!, placeholder: nil, options: .progressiveLoad)
        } else {
            profilImageView.image = #imageLiteral(resourceName: "ic_social_default_profil")
        }
    }
    
    @IBAction func sugestionActionTap(_ sender: Any) {
        suggestionLabel.textColor = ThemeColor.c01C7AD
        suggestionLine.image = UIImage(named: "img-bottom-ligne-select")
        swipeStarLabel.textColor = ThemeColor.cB8B8B8
        swipeStarLine.image = UIImage(named: "img-bottom-ligne-unselect")
        votesLabel.textColor = ThemeColor.cB8B8B8
        votesLine.image = UIImage(named: "img-bottom-ligne-unselect")
        
        UserService.shared.getMyPost(userId: self.userId) { posts in
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    @IBAction func swipeStarActionTap(_ sender: Any) {
        suggestionLabel.textColor = ThemeColor.cB8B8B8
        suggestionLine.image = UIImage(named: "img-bottom-ligne-unselect")
        swipeStarLabel.textColor = ThemeColor.c01C7AD
        swipeStarLine.image = UIImage(named: "img-bottom-ligne-select")
        votesLabel.textColor = ThemeColor.cB8B8B8
        votesLine.image = UIImage(named: "img-bottom-ligne-unselect")
        
        UserService.shared.getSurkiffPost(userId: self.userId) { posts in
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    @IBAction func votesActionTap(_ sender: Any) {
        suggestionLabel.textColor = ThemeColor.cB8B8B8
        suggestionLine.image = UIImage(named: "img-bottom-ligne-unselect")
        swipeStarLabel.textColor = ThemeColor.cB8B8B8
        swipeStarLine.image = UIImage(named: "img-bottom-ligne-unselect")
        votesLabel.textColor = ThemeColor.c01C7AD
        votesLine.image = UIImage(named: "img-bottom-ligne-select")
        
        UserService.shared.getLikePost(userId: self.userId) { posts in
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
}

extension ProfilV2ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (self.posts.count / 3) + (self.posts.count % 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.row % 2 == 0 ? ThreeProductCell.Odd : ThreeProductCell.Even
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ThreeProductCell else { return UITableViewCell() }

        cell.setup(
            product1: self.posts.getOrNil(indexPath.row*3),
            product2: self.posts.getOrNil(indexPath.row*3+1),
            product3: self.posts.getOrNil(indexPath.row*3+2),
            index: indexPath.row)
        
        cell.productClosure = { product in
            
        }
        
        return cell
    }
    
    @IBAction func takePictureActionTap(_ sender: Any) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        UserService.shared.getUser(userId: userId) { user in
            guard let user = user else { return }
            takePictureForPost(in: self, for: user)
        }
    }
}

extension ProfilV2ViewController: UITableViewDelegate {
    
}
