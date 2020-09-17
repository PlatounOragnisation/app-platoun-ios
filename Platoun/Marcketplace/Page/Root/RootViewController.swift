//
//  NavigationController.swift
//  DrawerMenuExample
//
//  Created by Florian Marcu on 1/17/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

protocol RootViewControllerDelegate: class {
    func rootViewControllerDidTapMenuButton(_ rootViewController: RootViewController)
    func delegateAction(_ delegate: DrawerViewControllerDelegate)
}

class RootViewController: UINavigationController, UINavigationControllerDelegate {
    
    static func instance() -> RootViewController {
        let vc = RootViewController.instanceStoryboard()
        vc.viewControllers = [ MarketplaceViewController.instance() ]
        return vc
    }
    
    
    //    fileprivate var menuButton: UIBarButtonItem!
    //    fileprivate var topNavigationLeftImage: UIImage?
    weak var drawerDelegate: RootViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    fileprivate var duringPushAnimation = false
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let rootViewController = navigationController as? RootViewController else { return }
        rootViewController.duringPushAnimation = false
    }
    func handleMenuButton() {
        drawerDelegate?.rootViewControllerDidTapMenuButton(self)
    }
    
    func setMenu(delegate: DrawerViewControllerDelegate) {
        drawerDelegate?.delegateAction(delegate)
    }
}

extension RootViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }
        
        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        return viewControllers.count > 1 && duringPushAnimation == false
        
    }
}
