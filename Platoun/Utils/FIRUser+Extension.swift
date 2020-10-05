//
//  FIRUser+Extension.swift
//  Platoun
//
//  Created by Flavian Mary on 02/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import FirebaseCore
import FirebaseAuth

enum UserError: Error {
    case loginPasswordNotSaved
    case authenticationUnknown
}

extension User {
    var isPassword: Bool {
        get { self.providerData.first?.providerID == "password" }
    }
    
    func getAuthentication() throws -> Authentication {
        switch self.providerData.first?.providerID {
        case "facebook.com": return .facebook
        case "google.com": return .google
        case "apple.com": return .apple
        case "password":
            if let lp = UserDefaults.standard.loginPassword {
                return .email(email: lp.login, password: lp.password)
            } else {
                throw UserError.loginPasswordNotSaved
            }
        default: throw UserError.authenticationUnknown
        }
    }
    
//    var authentication: Authentication? {
//        get {
//            switch self.providerData.first?.providerID {
//            case "facebook.com": return .facebook
//            case "google.com": return .google
//            case "apple.com": return .apple
//            case "password":
//                if let lp = UserDefaults.standard.loginPassword {
//                    return .email(email: lp.login, password: lp.password)
//                } else {
//                    fatalError("LoginPassword not saved")
//                }
//            default: fatalError("authentication unknown")
//            }
//        }
//    }
}
