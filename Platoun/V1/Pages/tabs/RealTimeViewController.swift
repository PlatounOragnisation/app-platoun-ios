//
//  RealTimeViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseCrashlytics


class RealTimeViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource: PlatounTableViewDataSource?
    
    
    func generateDataSource() {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateDataSource()
        self.dataSource?.bind(to: self.tableView)
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
    }
    
    @objc private func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.refreshControl?.tintColor = ThemeColor.BackgroundGradient2
        self.dataSource?.startObserve()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dataSource?.stopObserve()
    }
    
}
