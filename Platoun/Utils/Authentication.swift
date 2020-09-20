//
//  AuthWithFB.swift
//  Platoun
//
//  Created by Flavian Mary on 24/08/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FirebaseCrashlytics

enum AuthenticationError: Error {
    case cancel, googleAuthenticationIsNil, signInNoError, signUpNoError, reAuthWithoutCurrentUser
}

func AuthenticationLogout() {
    UserDefaults.standard.loginPassword = nil
    LoginManager().logOut()
    try? Auth.auth().signOut()
}

enum Authentication {
    typealias CallBack = (Result<AuthDataResult, Error>)->Void
    
    case apple
    case email(email: String, password: String)
    case facebook
    case google
    
    func signUp(from viewController: UIViewController, callBack: @escaping CallBack) {
        switch self {
        case .email(let email, let password):
            Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
                if let authData = authDataResult {
                    UserDefaults.standard.loginPassword = UserDefaults.LoginPassword(login: email, password: password)
                    callBack(Result.success(authData))
                } else {
                    Crashlytics.crashlytics().record(error: error ?? AuthenticationError.signUpNoError)
                    callBack(Result.failure(error ?? AuthenticationError.signUpNoError))
                }
            }
        default:
            self.signIn(from: viewController, callBack: callBack)
        }
    }
    
    func signIn(from viewController: UIViewController, callBack: @escaping CallBack) {
        self.getCredential(from: viewController) { credentialResult in
            switch credentialResult {
            case .success(let credential):
                Auth.auth().signIn(with: credential) { (authDataResult, error) in
                    if let authData = authDataResult {
                        switch self {
                        case .email(let email, let password):
                            UserDefaults.standard.loginPassword = UserDefaults.LoginPassword(login: email, password: password)
                        default: break
                        }
                        callBack(Result.success(authData))
                    } else {
                        Crashlytics.crashlytics().record(error: error ?? AuthenticationError.signInNoError)
                        callBack(Result.failure(error ?? AuthenticationError.signInNoError))
                    }
                }
            case .failure(let error):
                callBack(Result.failure(error))
            }
        }
    }
    
    func resetPassword(from viewController: UIViewController, callBack: @escaping (Result<Void,Error>)->Void) {
        switch self {
        case .email(let email, _):
            Auth.auth().sendPasswordReset(withEmail: email) { e in
                if let error = e {
                    Crashlytics.crashlytics().record(error: error)
                    callBack(Result.failure(error))
                } else {
                    callBack(Result.success(Void()))
                }
            }
        default: break
        }
    }
    
    func changePassword(from viewController: UIViewController, olPassword: String, newPassord: String, callBack: @escaping (Result<Void,Error>)->Void) {
        switch self {
        case .email(let email, _):
            let credential = EmailAuthProvider.credential(withEmail: email, password: olPassword)
            guard let currentUser = Auth.auth().currentUser else {
                callBack(Result.failure(AuthenticationError.reAuthWithoutCurrentUser)); return
            }
            currentUser.reauthenticate(with: credential) { (authDataResult, error) in
                guard authDataResult != nil else {
                    Crashlytics.crashlytics().record(error: error ?? AuthenticationError.signInNoError)
                    callBack(Result.failure(error ?? AuthenticationError.signInNoError)); return
                }
                
                currentUser.updatePassword(to: newPassord) { (error) in
                    if let e = error {
                        Crashlytics.crashlytics().record(error: e)
                        callBack(Result.failure(e))
                    } else {
                        callBack(Result.success(Void()))
                    }
                }
            }

        default: break
        }
    }
    
    func reAuth(from viewController: UIViewController, callBack: @escaping CallBack) {
        self.getCredential(from: viewController) { credentialResult in
            switch credentialResult {
            case .success(let credential):
                guard let currentUser = Auth.auth().currentUser else {
                    callBack(Result.failure(AuthenticationError.reAuthWithoutCurrentUser)); return
                }
                currentUser.reauthenticate(with: credential) { (authDataResult, error) in
                    if let authData = authDataResult {
                        callBack(Result.success(authData))
                    } else {
                        callBack(Result.failure(error ?? AuthenticationError.signInNoError))
                    }
                }
            case .failure(let error):
                
                callBack(Result.failure(error))
            }
        }
    }
    
    private func getCredential(from viewController: UIViewController, _ completion: @escaping (Result<AuthCredential, Error>)->Void) {
        switch self {
        case .apple:
            AppleSignInUtils.shared(from: viewController, completion: { result in
                switch result {
                    
                case .success((let tokenId, let nonce)):
                    let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenId, rawNonce: nonce)
                    completion(Result.success(credential))
                case .failure(let error):
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                }
            }).signIn()
        case .email(email: let email, password: let password):
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            completion(Result.success(credential))
        case .facebook:
            LoginManager().logIn(permissions: ["public_profile","email"], from: viewController) { (result, errorFB) in
                if let errorFB = errorFB {
                    Crashlytics.crashlytics().record(error: errorFB)
                    completion(Result.failure(errorFB))
                } else if let result = result, result.isCancelled {
                    completion(Result.failure(AuthenticationError.cancel))
                } else {
                    let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                    completion(Result.success(credential))
                }
            }
        case .google:
            GoogleSignInUtils.shared(from: viewController, completion: { result in
                switch result {
                case .success((let idToken, let accessToken)):
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: accessToken)
                    completion(Result.success(credential))
                case .failure(let error):
                    Crashlytics.crashlytics().record(error: error)
                    completion(Result.failure(error))
                }
            }).signIn()
        }
    }
}
