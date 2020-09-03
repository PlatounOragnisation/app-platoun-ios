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
    
    struct LoginPassword {
        let login: String
        let password: String
        
        static func initValue(_ dict: [String:String]) -> LoginPassword {
            return LoginPassword(login: dict["login"]!, password: dict["password"]!)
        }
        
        var map: [String: String] {
            get { ["login": login, "password": password] }
        }
    }
    var loginPassword: LoginPassword? {
        get {
            guard let lp = UserDefaults.standard.dictionary(forKey: "loginPassword") as? [String:String] else { return nil }
            return LoginPassword.initValue(lp)
        }
        set { UserDefaults.standard.set(newValue?.map, forKey: "loginPassword") }
    }
}
