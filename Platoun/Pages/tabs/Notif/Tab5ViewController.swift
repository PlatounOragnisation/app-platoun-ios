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
    
    var dataSource: EditableFirestoreTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else { return }
        self.tableView.delegate = self
        
        let query = FirestoreUtils.getNotificationsQuery(userId: currentUser.uid)
        
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
        guard
            let userId = Auth.auth().currentUser?.uid,
            let snap = self.dataSource?.snapshot(at: indexPath.row),
            let data = snap.data(),
            let notif = try? notificationParse(data, id: snap.documentID)
            else { return }
        
        if let statusNotification = notif as? StatusPlatounNotification {
            if statusNotification.status == .validated {
                let vc = Platoun.getNotificationViewController(currentUserId: userId, notificationSendBy: statusNotification.senderUserId, groupId: statusNotification.groupId)
                
                self.present(vc, animated: true)
            }
        } else {
            
        }
    }
}
