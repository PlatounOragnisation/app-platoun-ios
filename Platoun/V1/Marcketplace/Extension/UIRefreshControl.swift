//
//  UIRefreshControl.swift
//  Platoun
//
//  Created by Flavian Mary on 08/04/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func beginRefreshingManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: -frame.height), animated: true)
        }
        beginRefreshing()
    }
}
