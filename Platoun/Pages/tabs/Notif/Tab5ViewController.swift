//
//  Tab5ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseUI


class Tab5ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    
    var dataSource: EditableFirestoreTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = "Des notifications vous attendent !"
        guard let currentUser = Auth.auth().currentUser else { return }
        self.tableView.delegate = self
        
        let query = FirestoreUtils.getNotificationsOrderedQuery(userId: currentUser.uid)
        
        dataSource = EditableFirestoreTableViewDataSource(query: query, populateCell: { (tableView, indexPath, doc) -> UITableViewCell in
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell,
                let data = doc.data()
            else {
                return UITableViewCell()
            }
            
            do {
                let notif = try notificationParse(data, id: doc.documentID)
                if !notif.isRead {
                    doc.reference.setData(["isRead":true], merge: true)
                }
                cell.setup(notification: notif)
                return cell
            } catch {
                Crashlytics.crashlytics().record(error: error)
                return UITableViewCell()
            }
        })
        self.dataSource?.delegate = self
        
        self.dataSource?.queryErrorHandler = { error in
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
    var first = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if first {
            self.dataSource?.bind(to: self.tableView)
            first = false
        }
    }
}

extension Tab5ViewController: EditableFirestoreTableViewDataSourceDelegate {
    func deleteRow(indexPath: IndexPath) {
        guard let snap = self.dataSource?.snapshot(at: indexPath.row) else { return }
        snap.reference.delete { (error) in
            if let error = error {
                print(error)
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
}

extension Tab5ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let snap = self.dataSource?.snapshot(at: indexPath.row) else { return }
        actionNotifSnap(snap: snap, from: self)
    }
}

func actionNotif(notifId: String, from viewController: UIViewController) {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    FirestoreUtils.Notifications.getNotification(userId: userId, notifId: notifId) { result in
        switch result {
        case .success(let snap):
            actionNotifSnap(snap: snap, from: viewController)
        case .failure(let error):
            Crashlytics.crashlytics().record(error: error)
        }
    }
}

func actionNotifSnap(snap: DocumentSnapshot, from viewController: UIViewController) {
    guard
        let userId = Auth.auth().currentUser?.uid,
        let data = snap.data(),
        let notif = try? notificationParse(data, id: snap.documentID)
        else { return }
    
    if let statusNotification = notif as? StatusPlatounNotification {
        if statusNotification.status == .validated {
            Interactor.shared.fetchPromocodes(userId: userId) { (list) in
                guard let promocode = list.first(where: { $0.groupId == statusNotification.groupId }) else {
                    UIKitUtils.showAlert(in: viewController, message: "Le code promo a expiré.", completion: {})
                    return }
                
                let vc = SuccessViewController.instance(promocode: promocode.promoCodeValue, link: promocode.link)
                viewController.present(vc, animated: true)
            }
        }
    } else if let invitNotification = notif as? InvitPlatournNotification {
        let vc = NotificationInvitationViewController.instance(notification: invitNotification)
        viewController.present(vc, animated: true)
    } else if let commentNotification = notif as? CommentPlatounNotification {
        let vc = PostViewController.getInstance(notification: commentNotification)
        viewController.present(vc, animated: true)
    } else {
        
    }
}
