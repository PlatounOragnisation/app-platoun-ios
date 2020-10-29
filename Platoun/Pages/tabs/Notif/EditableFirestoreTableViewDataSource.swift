//
//  EditableFirestoreTableViewDataSource.swift
//  Platoun
//
//  Created by Flavian Mary on 30/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseUI

//protocol EditableFirestoreTableViewDataSourceDelegate {
//    func deleteRow(indexPath: IndexPath)
//}
//
//class EditableFirestoreTableViewDataSource: FUIFirestoreTableViewDataSource {
//    var delegate: EditableFirestoreTableViewDataSourceDelegate?
//    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        switch editingStyle {
//        case .delete:
//            self.delegate?.deleteRow(indexPath: indexPath)
//        case .insert: break
//        case .none: break
//        @unknown default: break
//        }
//    }
//}
