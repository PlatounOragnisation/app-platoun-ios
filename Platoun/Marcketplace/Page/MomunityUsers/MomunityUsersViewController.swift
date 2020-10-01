//
//  MomunityUsersViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 24/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseMessaging
import FirebaseFirestore
import Alamofire

protocol MomunityUsersViewControllerDelegate {
    func onClose(viewController: MomunityUsersViewController)
}

class MomunityUsersViewController: LightViewController {
    
    static func instance(productId: String, groupId: String, delegate: MomunityUsersViewControllerDelegate) -> MomunityUsersViewController {
        let vc = MomunityUsersViewController.instanceStoryboard()
        vc.productId = productId
        vc.groupId = groupId
        vc.delegate = delegate
        return vc
    }
    
    var productId: String!
    var groupId: String!
    var users: [PlatounUser] = []
    
    var userSelectedIndex: [PlatounUser] = []
    
    var delegate: MomunityUsersViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.delegate?.onClose(viewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tableView.refreshControl = UIRefreshControl()
    }
    
    func update(_ search: String) {
        guard search.count >= 3 else {
            self.users = []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
            return }
        self.tableView.refreshControl?.beginRefreshing()
        FirestoreUtils.getUsers(search: search) { result in
            switch result {
            case .success(let listUsers):
                self.users = listUsers
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
    
    @IBAction func actionDiscard(_ sender: Any) {
        if self.userSelectedIndex.count > 0 {
            let alert = UIAlertController(title: "Be careful !".localise(), message:
                "You must click on 'Apply' to invite".localise()
                    + " \(self.userSelectedIndex.map { $0.displayName ?? "No name" }.joined(separator: " & ")).", preferredStyle: .alert)

            let backAction =  UIAlertAction(title: "Keep leaving".localise(), style: .default) { _ in
                self.delegate?.onClose(viewController: self)
            }
            backAction.setValue(UIColor(hex: "#222222")!, forKey: "titleTextColor")
            alert.addAction(backAction)

            
            let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
            action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")

            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        self.delegate?.onClose(viewController: self)
    }
    
    @IBAction func actionApply(_ sender: Any) {
        if self.userSelectedIndex.count > 0 {
            self.sendInvitation(users: self.userSelectedIndex, index: 0)
            return
        }
        
        let alert = UIAlertController(title: "Oups !".localise(), message: "You didn't select any friends.".localise(), preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
        action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
        
        alert.addAction(action)
        self.present(alert, animated: true)
        return
    }
    
    func sendNotif(fcmToken: String, notif: InvitPlatournNotification) {
        AF.request(
            "https://fcm.googleapis.com/fcm/send",
            method: .post,
            parameters: [
                "notification": [
                    "body": notif.message,
                    "title": notif.title
                ],
                "data": [
                    "notifId": notif.id
                ],
                "to": fcmToken
            ],
            encoding: JSONEncoding(),
            headers: [
                "Content-Type": "application/json",
                "Authorization": "key=AAAAEv-sP9w:APA91bEswEMe3nFEpiMRrUZQJkYxgMqtZaMDvbHOZKNbVCIlhUEN91guSL663D5_IjWawiZQnCYwwMaIns7UsK4-8GX52UmwuMIbsLINjJUsAjpv2-VW0nkOEy8h4iGwsXEZM8NyLL4q"
            ])
            .response { response in
                print(response)
            }
    }
    
    func sendInvitation(users: [PlatounUser], index: Int) {
        guard let user = Auth.auth().currentUser else { return }
        
        let message = (user.displayName ?? "").isEmpty
            ? "Une personne t’invite à rejoindre son groupe"
            : "\(user.displayName!) t’invite à rejoindre son groupe"
        
        
        let notif = InvitPlatournNotification(
            id: UUID().uuidString,
            title: "L’offre expire bientôt.",
            message: message,
            senderUserId: user.uid,
            senderName: user.displayName,
            groupId: self.groupId)
        
        
        FirestoreUtils.saveInvitNotification(userId: users[index].uid, notif: notif) { result in
            switch result {
            case .success():
                if let token = users[index].fcmToken {
                    self.sendNotif(fcmToken: token, notif: notif)
                }
                if index == users.count - 1 {
                    let vc = InviteSuccessViewController.instance(delegate: self)
                    self.present(vc, animated: true)
                } else {
                    self.sendInvitation(users: users, index: index + 1)
                }
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
                UIKitUtils.showAlert(in: self, message: "Désolé. Une erreur est survenue lors de l'invitation.") {}
            }
        }
    }
}

// MARK: - InviteSuccessViewControllerDelegate
extension MomunityUsersViewController: InviteSuccessViewControllerDelegate {
    func backAfterSuccess(_ viewController: InviteSuccessViewController) {
        viewController.dismiss(animated: true) {
            self.delegate?.onClose(viewController: self)
        }
    }
}

extension MomunityUsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.update(searchText)
    }
}

// MARK: - UserCellDelegate
extension MomunityUsersViewController: UserCellDelegate {
    func onClicInvite(user: PlatounUser) {
        if let index = self.userSelectedIndex.firstIndex(where: { $0.uid == user.uid }) {
            self.userSelectedIndex.remove(at: index)
        } else if userSelectedIndex.count >= 2 {
            let alert = UIAlertController(title: "Sorry !".localise(), message: "You can only invite one person at a time".localise(), preferredStyle: .alert)
            let action = UIAlertAction(title: "OK".localise(), style: .default, handler: nil)
            action.setValue(UIColor(hex: "#038091")!, forKey: "titleTextColor")
            
            alert.addAction(action)
            self.present(alert, animated: true)
        } else {
            self.userSelectedIndex.append(user)
        }
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension MomunityUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserCell else { return UITableViewCell() }
        
        let user = self.users[indexPath.row]
        let isSelected = self.userSelectedIndex.contains(where: { $0.uid == user.uid })
        
        cell.setup(user: user, delegate: self, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MomunityUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? UserCell)?.cancel()
    }
}
