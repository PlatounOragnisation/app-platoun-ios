//
//  UITableView+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 08/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let section = self.numberOfSections
        if section > 0 {
            let row = self.numberOfRows(inSection: section - 1)
            if row > 0 {
                self.scrollToRow(at: IndexPath(row: row - 1, section: section - 1), at: .bottom, animated: animated)
            }
        }
    }
}
