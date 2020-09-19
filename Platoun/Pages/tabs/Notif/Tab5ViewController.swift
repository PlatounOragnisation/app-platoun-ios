//
//  Tab5ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI


class Tab5ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
        
    var dataSource: FUIFirestoreTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else { return }
        let query = FirestoreUtils.getNotificationsQuery(userId: currentUser.uid)

        dataSource = FUIFirestoreTableViewDataSource(query: query, populateCell: { (tableView, indexPath, doc) -> UITableViewCell in
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell,
                    let notif = try? doc.data(as: Notification.self) else {
                    return UITableViewCell()
                }
                cell.setup(notification: notif)
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

extension Tab5ViewController: UITableViewDelegate {
    
}
