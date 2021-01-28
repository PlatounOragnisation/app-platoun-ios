//
//  GoogleSignIn.swift
//  Platoun
//
//  Created by Flavian Mary on 03/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import GoogleSignIn

enum SignInError: Error {
    case cancelByUser
}

class GoogleSignInUtils: NSObject {
    typealias SignInResult = Result<(String,String),Error>
    fileprivate static var instance: GoogleSignInUtils?
    
    static func shared(from viewController: UIViewController, completion: @escaping (SignInResult)->Void) -> GoogleSignInUtils {
        instance = instance ?? GoogleSignInUtils(from: viewController, callBack: completion)
        instance?.callBack = completion
        instance?.viewController = viewController
        return instance!
    }
    
    fileprivate var callBack: (SignInResult)->Void
    fileprivate var viewController: UIViewController {
        didSet {
            GIDSignIn.sharedInstance().presentingViewController = self.viewController
        }
    }
    
    fileprivate init(from viewController: UIViewController, callBack: @escaping (SignInResult)->Void) {
        self.callBack = callBack
        self.viewController = viewController
        super.init()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
}

extension GoogleSignInUtils: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn?, didSignInFor user: GIDGoogleUser?, withError error: Error!) {
        guard let authentication = user?.authentication, error == nil else {
            if (error as NSError).code == GIDSignInErrorCode.canceled.rawValue {
                self.callBack(.failure(SignInError.cancelByUser))
            } else {
                self.callBack(Result.failure(error ?? AuthenticationError.googleAuthenticationIsNil))
            }
            return
        }
        
        self.callBack(Result.success((authentication.idToken, authentication.accessToken)))        
    }
}
