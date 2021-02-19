//
//  ProfilV2ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 06/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit
import Shuffle
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
    
    lazy var contentCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var cardSwip: SwipeCard = {
        let card = SwipeCard()
        card.footerHeight = 0
        card.swipeDirections = []
        card.translatesAutoresizingMaskIntoConstraints = false
        
        card.content = PostCardView(isSmallVersion: false, canChangeSize: false)
        (card.content as! PostCardView).delegate = self
        return card
    }()
    
    lazy var widthAnchorContent = contentCard.widthAnchor.constraint(equalToConstant: 0)
    lazy var heightAnchorContent = contentCard.heightAnchor.constraint(equalToConstant: 0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.initPlatounTheme(isTransparent: true)
        self.navigationItem.initTitleItem()

        profilImageView.layer.cornerRadius = 16
        profilImageView.layer.masksToBounds = true
        
        votesCountLabel.update(colors: [ThemeColor.cFFE600, ThemeColor.cFFC7C7])
        votesTitleLabel.update(colors: [ThemeColor.cFFE600, ThemeColor.cFFC7C7])
                
        self.loadUser(userId: self.userId) { user in
            guard let user = user else { return }
            self.user = user
            self.initializeUser()
        }
        
        self.sugestionActionTap("")
    }
    
    func loadUser(userId: String, completion: @escaping (UserV2?)->Void) {
        UserService.shared.getUser(userId: self.userId) { user in
            completion(user)
        }
    }
    
    private var user: UserV2!
    private var posts: [ProductVote] = []
    
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.initializeCard()
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
    
    func initializeCard() {
        view.addSubview(contentCard)
        contentCard.addSubview(cardSwip)
                
        let constraints = [
            contentCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            widthAnchorContent,
            heightAnchorContent,
            
            cardSwip.topAnchor.constraint(equalTo: contentCard.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardSwip.centerXAnchor.constraint(equalTo: contentCard.safeAreaLayoutGuide.centerXAnchor),
            cardSwip.widthAnchor.constraint(equalTo: contentCard.safeAreaLayoutGuide.widthAnchor, multiplier: 0.96),
            cardSwip.heightAnchor.constraint(equalTo: contentCard.safeAreaLayoutGuide.heightAnchor, multiplier: 1, constant: -80)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func showCard(post: PostV2) {
        (self.cardSwip.content as? PostCardView)?.update(with: post)
        self.heightAnchorContent.constant = self.view.frame.height
        self.widthAnchorContent.constant = self.view.frame.width

        UIView.animate(withDuration: 0.3) {
            self.cardSwip.superview?.layoutIfNeeded()
        }
    }
    
    func hideCard() {
        self.heightAnchorContent.constant = 0
        self.widthAnchorContent.constant = 0

        UIView.animate(withDuration: 0.3) {
            self.cardSwip.superview?.layoutIfNeeded()
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
            PostService.shared.getPost(postId: product.postId) { (post) in
                self.showCard(post: post)
            }
        }
        
        return cell
    }
    
    @IBAction func takePictureActionTap(_ sender: Any) {
        if let userId = Auth.auth().currentUser?.uid {
            self.loadUser(userId: userId) { user in
                guard let user = user else { return }
                takePictureForPost(in: self, for: user)
            }
        } else {
            let vc = UIAlertController.askAuth(in: self) { (successAuth) in
                guard successAuth, let userId = Auth.auth().currentUser?.uid else { return }
                self.loadUser(userId: userId) { (user) in
                    guard let user = user else { return }
                    takePictureForPost(in: self, for: user)
                }
            }
            self.present(vc, animated: true)
        }
    }
}

extension ProfilV2ViewController: UITableViewDelegate {
    
}

extension ProfilV2ViewController: PostCardViewDelegate {
    func getParentViewController() -> UIViewController {
        return self
    }
    
    func getBottomConstraint() -> NSLayoutConstraint? {
        return nil
    }
    
    func sizeChange(isSmallVersion: Bool) {
        
    }
    
    func footerOnClick() {
        self.hideCard()
    }
}
