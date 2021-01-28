//
//  LaunchViewController.swift
//  Platoun
//
//  Created by Flavian Mary on 02/11/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class LaunchViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        RemoteConfigUtils.shared.initialize {
            self.checkVersion()
        }
    }
    
    func checkVersion() {
        let minimalVersion = RemoteConfigUtils.shared.getMinimalVersion()
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { self.showApp(); return }
        let compare = minimalVersion.minimalVersion.compare(appVersion, options: .numeric)
        if minimalVersion.unauthorizedVersions.contains(appVersion) {
            self.showUpgrade()
        } else {
            
            switch compare {
            case .orderedAscending:     // appVersion > minimalVersion
                self.showApp()
            case .orderedSame:          // appVersion == minimalVersion
                self.showApp()
            case .orderedDescending:    // appVersion < minimalVersion
                self.showUpgrade()
            }
        }
    }
    
    func showUpgrade() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showUpgrade", sender: nil)
        }
    }
    
    func showApp() {
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).displayV2()
        }
    }
}
