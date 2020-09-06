//
//  Tab4ViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseUI

class Tab4ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataSource: FUIFirestoreTableViewDataSource = {
        let query = FirestoreUtils.getPostQuery()
        return self.tableView.bind(toFirestoreQuery: query) { (tableView, indexPath, doc) -> UITableViewCell in
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: QuestionTableViewCell.identifier, for: indexPath) as? QuestionTableViewCell,
                let post = try? doc.data(as: Post.self) else {
                return UITableViewCell()
            }
            FirestoreUtils.getUserInfo(uid: post.createBy) { result in
                switch result {
                case .success((let name, let photo)):
                    cell.setup(post: post, userName: name, userPhoto: photo)
                case .failure(let error):
                    cell.setup(post: post, userName: "", userPhoto: nil)
                }
            }
            return cell
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self.dataSource

        // Do any additional setup after loading the view.
    }
    


    

}
