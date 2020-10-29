//
//  TabViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 24/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseFirestore

enum QueryError: Error {
    case noSnapshot
}

class TabViewController: UITabBarController {
    let loginSegue = "displayAuth"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.selectedIndex = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let user = user else { return }
            
            FirestoreUtils.getNotificationsQuery(userId: user.uid).addSnapshotListener { (snaps, error) in
                guard let snaps = snaps, error == nil else { Crashlytics.crashlytics().record(error: error ?? QueryError.noSnapshot); return }
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: Date())
                let start = calendar.date(from: components)!
                let end = calendar.date(byAdding: .day, value: -3, to: start)!

                
                var pastNotif: [QueryDocumentSnapshot] = []
                var unReadNotif: [QueryDocumentSnapshot] = []
                
                for doc in snaps.documents {
                    guard let timestamp = doc.data()["dateTimeCreation"] as? Timestamp else { continue }
                    
                    if timestamp.dateValue() < end {
                        pastNotif.append(doc)
                    } else {
                        let isRead = (doc.data()["isRead"] as? Bool) ?? false

                        if !isRead {
                            unReadNotif.append(doc)
                        }
                    }
                }
                self.removeNotif(snaps: pastNotif)
                
                if unReadNotif.count > 0 {
                    self.viewControllers?.last?.tabBarItem.image = #imageLiteral(resourceName: "ic_tab_notif_unselect_dot")
                    self.viewControllers?.last?.tabBarItem.selectedImage = #imageLiteral(resourceName: "ic_tab_notif_selected_dot")
                } else {
                    self.viewControllers?.last?.tabBarItem.image = #imageLiteral(resourceName: "ic_tab_notif_unselect")
                    self.viewControllers?.last?.tabBarItem.selectedImage = #imageLiteral(resourceName: "ic_tab_notif_selected")
                }
                
            }

        }
        
    }
    
    func stopBind() {
        self.viewControllers?.getOrNil(4)
    }
    
    func removeNotif(snaps: [QueryDocumentSnapshot]) {
        snaps.forEach { snap in
            snap.reference.delete()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.connexion()
    }
    
    func connexion() {
        if Auth.auth().currentUser == nil {
            LoginViewController.show(in: self) { isConnected in
                if !isConnected {
                    UIKitUtils.showAlert(in: self, message: "Vous devez être connecter pour continuer") {
                        self.connexion()
                    }
                } else {
                    
                    let reloader: ReloadedViewController?
                    if let nav = self.selectedViewController as? UINavigationController {
                        reloader = nav.topViewController as? ReloadedViewController
                    } else {
                        reloader = self.selectedViewController as? ReloadedViewController
                    }
                    reloader?.reload()
                }
            }
        }
    }
}

extension TabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return Auth.auth().currentUser != nil
    }
}
