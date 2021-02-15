//
//  SwipeViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 26/01/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import UIKit
import Shuffle
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics

class SwipeViewController: UIViewController {
    
    private let cardStack = SwipeCardStack()
    private let buttonStackView = ButtonStackView()
    
    @IBOutlet weak var bottomTab: UIView!
    
    
    private var posts: [PostV2] = []
    private var user: UserV2?
    private var lastSnapshot: DocumentSnapshot?
    @IBOutlet weak var votesCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueCenterConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        self.setGradientBackground(self.view)
        super.viewWillAppear(animated)
        self.navigationController?.initPlatounTheme(isTransparent: true)
        
        self.navigationItem.initTitleItem()
        self.navigationItem.initLeftItem(target: self, actionTap: #selector(actionTapProfil))
        self.navigationItem.initRightItem(target: self, actionTap: #selector(actionTapRing))
        
        if let userId = Auth.auth().currentUser?.uid {
            UserService.shared.getUser(userId: userId) { (user: UserV2?) in
                guard let user = user else { return }
                self.user = user
                self.loadData()
            }
        } else {
            self.loadData()
        }
        
        let userIdBis = Auth.auth().currentUser?.uid
        let key = "love_swipe_feature_voted_\(userIdBis ?? "")"
        
        let displayVote = userIdBis != nil && !UserDefaults.standard.bool(forKey: key)
        
        votesCenterConstraint.isActive = displayVote
        continueCenterConstraint.isActive = !displayVote
        
//        voteTitle.isHidden = !displayVote
//        voteButtonContainer.isHidden = !displayVote
    }
    
    func hideStackSwipe() {
        self.cardStack.isUserInteractionEnabled = false
    }
    
    func showStackSwipe() {
        self.cardStack.isUserInteractionEnabled = true
    }
    
    func loadData() {
        PostService.shared.getRecentPost(user: self.user, limit: 50, lastSnapshot: self.lastSnapshot) { (posts, snapshot) in
            let postsWithoutTwin = posts//.filter { new in !self.posts.contains(where: { $0.postId == new.postId }) }
            let oldModelsCount = self.posts.count
            let newModelsCount = oldModelsCount + postsWithoutTwin.count
            self.posts += postsWithoutTwin
            if postsWithoutTwin.count > 0 {
                self.showStackSwipe()
            } else if self.posts.count == 0 {
                self.hideStackSwipe()
            }
            self.lastSnapshot = snapshot
            let newIndices = Array(oldModelsCount..<newModelsCount)
            self.cardStack.appendCards(atIndices: newIndices)
        }
    }
    
    func showConnection() {
        let vc = UIAlertController(title: "Oups", message: "Vous devez pour le moment être connecté.", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(vc, animated: true)
    }
    
    @objc private func actionTapProfil() {
        guard let user = Auth.auth().currentUser?.uid else { return }
        self.performSegue(withIdentifier: "showProfil", sender: user)
    }
    @objc private func actionTapRing() {
        
    }
    
    func setGradientBackground(_ view: UIView) {
        let colorTop =  ThemeColor.cFEFEFE.cgColor
        let colorBottom = ThemeColor.cF7F6FB.cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self
        
        layoutButtonStackView()
        layoutCardStackView()
    }
        
    func card(fromImage image: UIImage) -> SwipeCard {
        let card = SwipeCard()
        card.swipeDirections = [.left, .right]
        card.content = UIImageView(image: image)
        
        let leftOverlay = UIView()
        leftOverlay.backgroundColor = .green
        
        let rightOverlay = UIView()
        rightOverlay.backgroundColor = .red
        
        card.setOverlays([.left: leftOverlay, .right: rightOverlay])
        
        return card
    }
    
    private func layoutButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                               bottom: bottomTab.topAnchor,
                               right: view.safeAreaLayoutGuide.rightAnchor,
                               paddingLeft: 0,
                               paddingBottom: 14,
                               paddingRight: 0)
    }
    
    var bottomConstraint: NSLayoutConstraint?
    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        bottomConstraint = self.cardStack.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1, constant: -145)
        
        let constraints = [
            cardStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            cardStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.96),
            bottomConstraint!
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showProfil":
            guard
                let destination = segue.destination as? ProfilV2ViewController,
                let userId = sender as? String else { return }
            destination.userId = userId
        default:
            break
        }
    }
    
}

extension SwipeViewController: ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate, ActionCardDelegate {
    func moreTapAction(productCard: PostV2) {
        let alert = UIAlertController(title: nil, message: "Que souhaitez-vous faire ?", preferredStyle: .alert)
        
        if productCard.user.id == self.user?.id {
            alert.addAction(UIAlertAction(title: "Supprime le", style: .cancel, handler: { _ in
                
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Signale le", style: .cancel, handler: { _ in
                
            }))
        }
        self.present(alert, animated: true)
    }
    
    func userNameTapAction(productCard: PostV2) {
        self.performSegue(withIdentifier: "showProfil", sender: productCard.user.id)
    }
    
    func shareImage(image: UIImage, productCard: PostV2) {
        let imageToShare:[Any] = [ image ]
        
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        print("PostService => load card n°\(index)")
        if index >= (self.posts.count - 4) && self.lastSnapshot != nil {
            self.loadData()
        }
        
        let card = SwipeCard()
        card.footerHeight = 0
        card.swipeDirections = [.left, .up, .right]
        for direction in card.swipeDirections {
            card.setOverlay(ProductCardOverlay(direction: direction), forDirection: direction)
        }
        
        let model = self.posts[index]
        card.content = ProductCardContentView()
        (card.content as! ProductCardContentView).delegate = self
        (card.content as! ProductCardContentView).update(with: model)
        //        card.footer = ProductCardFooterView(withTitle: "\(model.productName)", subtitle: model.userName)
        
        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return posts.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Swiped all cards!")
        self.hideStackSwipe()
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(self.posts[index].name)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        guard let user = self.user,let post = self.posts.getOrNil(index) else { return }
        print("Swiped \(direction) on \(post.name)")
        
        switch direction {
        case .left:
            VotesService.shared.seePost(user: user, post: post){}
        case .right:
            VotesService.shared.likePost(user: user, post: post, surkiff: false) {}
        case .up:
            VotesService.shared.likePost(user: user, post: post, surkiff: true) {}
        case .down:
            break
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
        guard
            let card = cardStack.card(forIndexAt: index),
            let content = card.content as? ProductCardContentView
            else { return }
        
        if content.isIncrease {
            card.swipeDirections = [.left, .up, .right]
        } else {
            card.swipeDirections = []
        }
        let (animate, complet) = content.toogleIncrease()
        
        UIView.animate(withDuration: 0.3, animations: {
            if content.isIncrease { self.bottomConstraint?.constant = -80 }
            else { self.bottomConstraint?.constant = -145 }
            animate()
            card.layoutIfNeeded()
            self.cardStack.superview?.layoutIfNeeded()
        }) { _ in
            complet()
        }
    }
    
    func didTapButton(buttonType: ButtonStackView.ButtonType) {
        switch buttonType {
        case .category:
            let vc = UIAlertController.getFeatureAvailableSoon()
            self.present(vc, animated: true)
        case .pass:
            cardStack.swipe(.left, animated: true)
        case .star:
            cardStack.swipe(.up, animated: true)
        case .like:
            cardStack.swipe(.right, animated: true)
        case .messages:
            let vc = UIAlertController.getFeatureAvailableSoon()
            self.present(vc, animated: true)
        }
    }
    
    
    @IBAction func takePictureActionTap(_ sender: Any) {
        guard let user = self.user else { return }
        takePictureForPost2(in: self, for: user)
    }
    
    @IBAction func yesActionTap() {
        guard
            let userId = Auth.auth().currentUser?.uid,
            !UserDefaults.standard.bool(forKey: "love_swipe_feature_voted_\(userId)") else { return }
        Analytics.logEvent("love_swipe_feature_yes", parameters: [
            AnalyticsParameterItemID: "love_swipe_feature",
            AnalyticsParameterItemName: "yes"
        ])
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "love_swipe_feature",
            AnalyticsParameterItemName: "yes"
        ])
        UserDefaults.standard.set(true, forKey: "love_swipe_feature_voted_\(userId)")
        
        UIView.animate(withDuration: 0.3) {
            self.votesCenterConstraint.isActive = false
            self.continueCenterConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func noActionTap() {
        guard
            let userId = Auth.auth().currentUser?.uid,
            !UserDefaults.standard.bool(forKey: "love_swipe_feature_voted_\(userId)") else { return }
        Analytics.logEvent("love_swipe_feature_no", parameters: [
            AnalyticsParameterItemID: "love_swipe_feature",
            AnalyticsParameterItemName: "no"
        ])
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "love_swipe_feature",
            AnalyticsParameterItemName: "no"
        ])
        UserDefaults.standard.set(true, forKey: "love_swipe_feature_voted_\(userId)")
                
        UIView.animate(withDuration: 0.3) {
            self.votesCenterConstraint.isActive = false
            self.continueCenterConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
    }
}
