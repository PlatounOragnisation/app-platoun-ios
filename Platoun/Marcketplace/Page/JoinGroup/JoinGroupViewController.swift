//
//  JoinGroupViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 22/02/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics

extension Array where Element: Equatable {
    mutating func appendIfDontExist(_ value: Element) {
        if self.firstIndex(of: value) == nil {
            self.append(value)
        }
    }
    
    mutating func appendIfDontExist(_ values: [Element]) {
        values.forEach {
            if self.firstIndex(of: $0) == nil {
                self.append($0)
            }
        }
    }
}

class JoinGroupViewController: PUIViewController, UISearchBarDelegate {
    static func instance(product: ProductSummary, scrollBottom: Bool) -> JoinGroupViewController {
        let viewController = JoinGroupViewController.instanceStoryboard()
        viewController.product = product
        viewController.scrollBottom = scrollBottom
        return viewController
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchBarIsVisible = false {
        didSet {
            self.searchBar.isHidden = !self.searchBarIsVisible
            self.titleLabel.isHidden = self.searchBarIsVisible
            self.searchButton.isHidden = self.searchBarIsVisible
        }
    }
    
    private var product: ProductSummary!
    var scrollBottom: Bool!
    
    private var groups: [Group] = []
    var users: [String: PlatounUser] = [:]
    var groupIsLoading: String?
        
    func reload(_ completion: (()-> Void)? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Interactor.shared.fetchGroups(userId: userId, productId: product.id) { groups in
            self.groupIsLoading = nil
            self.groups = groups
                .filter({ $0.maxUsers > $0.users.count })
                .sorted(by: { $0.endDate < $1.endDate })
            
            let temp: [String] = self.groups.flatMap { group -> [String] in
                let ids = group.users.map { $0.id }
                return ids + [group.groupCreator.id]
            }
            
            var userIds = [String]()
            userIds.appendIfDontExist(temp)
            
            FirestoreUtils.Users.getUsers(ids: userIds) { result in
                switch result {
                case .success(let users):
                    self.users = users
                    DispatchQueue.main.async {
                        self.showOrHideTableView()
                        self.tableView.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                        if self.scrollBottom {
                            self.scrollBottom = false
                            self.tableView.scrollToBottom(animated: true)
                        }
                        completion?()
                    }
                case .failure(let error):
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        }
    }
    
    @objc func pullToRefresh() {
        self.reload()
    }
    
    func showOrHideTableView() {
        let emptyViewIsHidden = self.getVisibleGroups().count > 0
        self.emptyView.isHidden = emptyViewIsHidden
        self.mainView.isHidden = !emptyViewIsHidden
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.showOrHideTableView()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
        if self.searchBar.text?.isEmpty ?? true {
            self.searchBarIsVisible = false
        }
    }
            
    @IBAction func actionCreateGroup(_ sender: Any) {
        let vc = CreateGroupViewController.instance(product: self.product) { (productId: String, groupId: String, text: String) in
            let congrat = CongratulationViewController.instance(productId: productId, groupId: groupId, text: text) {
                self.scrollBottom = true
                self.viewBecomeFirst()
            }
            
            self.newPresent(congrat, animated: true, completion: nil)
        }
        self.newPresent(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionSearch(_ sender: Any) {
        self.searchBarIsVisible = true
        self.searchBar.becomeFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    override func viewBecomeFirst() {
        self.tableView.refreshControl?.beginRefreshingManually()
        self.reload() {}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = 34
        view.layer.masksToBounds = true
    }
    
    func getVisibleGroups() -> [Group] {
        if self.searchBarIsVisible && !(self.searchBar.text?.isEmpty ?? true){
            let text = self.searchBar.text ?? ""
            return self.groups.filter {
                self.users[$0.groupCreator.id]?.displayName?.lowercased() .contains(text.lowercased()) ?? false }
        } else {
            return self.groups
        }
    }
}

extension JoinGroupViewController: InviteViewControllerDelegate {
    func invitationClose(_ viewController: InviteViewController, animated: Bool) {
        viewController.dismiss(animated: animated)
    }
    
    func showInvitation(_ invitation: InvitationType) {
        Invitation().show(in: self, type: invitation)
    }
}

extension JoinGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getVisibleGroups().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.identifier, for: indexPath) as? GroupCell else {
            return UITableViewCell()
        }
        let group = self.getVisibleGroups()[indexPath.row]
        cell.setup(group: group, users: self.users, delegate: self, isLoading: group.id == groupIsLoading)
        cell.startTimer()
        return cell
    }
}

extension JoinGroupViewController: GroupCellDelegate {
    
    func sendInvitation(_ cell: GroupCell, group: Group) {
        let vc = InviteViewController.instance(productId: group.productId, groupId: group.id, delegate: self)
        self.newPresent(vc, animated: true, completion: nil)
    }
    
    func iamCreator(_ cell: GroupCell, group: Group) {
        
        var message: String = "You can’t leave your own group".localise()
        
        if group.isPrivate {
            message += "\n&\n"
            message += "Your PIN code is".localise() + ": \(group.code ?? "")"
        } else {
            message += "."
        }
        
        
        let alert = UIAlertController(title: "Reminder :".localise(), message: message, preferredStyle: .alert)
                
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: alert.title ?? "",
                                                   attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]))
        
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
        action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func endOfTime() {
        let alert = UIAlertController(title: "Sorry !".localise(), message: "The deadline to join this group has been exceeded.".localise(), preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
        action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func leaveGroup(_ cell: GroupCell, group: Group) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupIsLoading = group.id
        self.tableView.reloadData()
        Interactor.shared.deleteUserInGroup(groupId: group.id, productId: group.productId, userId: userId) { isLeaved in
            self.groupIsLoading = nil
            guard let index = self.groups.firstIndex(where: { $0.id == group.id }) else { return }
            if isLeaved {
                self.groups[index].haveJoin = false
                if let userIndex = self.groups[index].users.firstIndex(where: { $0.id == userId }) {
                    self.groups[index].users.remove(at: userIndex)
                }
            }

            self.tableView.reloadData()
        }
    }
    
    func joinGroup(_ cell: GroupCell, group: Group) {
        guard let currentUser = Auth.auth().currentUser else { return }
        groupIsLoading = group.id
        self.tableView.reloadData()
        Interactor.shared.joinGroup(groupId: group.id, productId: group.productId, userId: currentUser.uid) { (join: Join?, error: String?) in
            self.groupIsLoading = nil
            
            if let message = error {
                let alert = UIAlertController(title: "Oups !".localise(), message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
                action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
                
                alert.addAction(action)
                self.tableView.reloadData()
                self.present(alert, animated: true)
                return
            }
            
            guard let index = self.groups.firstIndex(where: { $0.id == group.id }) else { return }
            guard let join = join else { return }
            
            if join.isJoined {
                self.groups[index].haveJoin = true
                self.groups[index].users.append(Group.User(id: currentUser.uid))
                self.users[currentUser.uid] = PlatounUser(uid: currentUser.uid, fcmToken: nil, displayName: currentUser.displayName, photoUrl: currentUser.photoURL?.absoluteString, groupNotification: true, trendsNotification: true, newsNotification: true)
            }
            self.tableView.reloadData()
            self.validateJoin(group: group, join: join)
        }
    }
    
    func validateJoin(group: Group, join: Join) {
        let vc: UIViewController
        if join.isCompleted, let promocode = join.promocode, let link = join.link {
            vc = SuccessViewController.instance(promocode: promocode, link: link)
        } else if join.isJoined {
            vc = CongratulationViewController.instance(productId: group.productId, groupId: group.id, text: nil, finish: {})
        } else {
            return
        }
        self.newPresent(vc, animated: true)
    }
    
    func joinPrivateGroup(_ cell: GroupCell, group: Group, forJoin: Bool) {
        let vc = PinCodeViewController.instance(correctPin: group.code, success: { _ in
            if forJoin {
                self.joinGroup(cell, group: group)
            } else {
                self.sendInvitation(cell, group: group)
            }
        })
        
        self.newPresent(vc, animated: true, completion: nil)
    }
}


extension JoinGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
