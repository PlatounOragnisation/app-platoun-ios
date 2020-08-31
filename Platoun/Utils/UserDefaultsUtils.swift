//
//  UserDefaultsUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 28/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation

extension UserDefaults {
    var phoneNumberVerificationID: String? {
        get { UserDefaults.standard.string(forKey: "authVerificationID") }
        set { UserDefaults.standard.set(newValue, forKey: "authVerificationID") }
    }
}
