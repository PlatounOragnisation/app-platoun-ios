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
import CryptoKit
import AuthenticationServices
import GoogleSignIn

protocol FirebaseUtilsDelegate {
    func firebaseAuth(result: AuthDataResult)
    func firebaseAuthError(error: Error)
}

class FirebaseUtils: NSObject {
    var delegate: FirebaseUtilsDelegate?
    weak var viewController: UIViewController?
    var isForCredential: Bool = false
    
    init(delegate: FirebaseUtilsDelegate? = nil) {
        self.delegate = delegate
    }
    
    static func logout() {
        do {
            LoginManager().logOut()
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func googleSignIn(from viewController: UIViewController, isForCredential: Bool) {
        self.viewController = viewController
        self.isForCredential = isForCredential
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func facebookLogIn(from viewController: UIViewController, isForCredential: Bool) {
        self.viewController = viewController
        self.isForCredential = isForCredential
        LoginManager().logIn(permissions: ["public_profile","email"], from: viewController) { (result, errorFB) in
            if let errorFB = errorFB {
                print("Login FB error: \(errorFB.localizedDescription)")
            } else if let result = result, result.isCancelled {
                print("Login FB cancelled")
            } else {
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.signIn(credential: credential)
            }
        }
    }
    
    func appleLogIn(from viewController: UIViewController, isForCredential: Bool) {
        self.viewController = viewController
        self.isForCredential = isForCredential
        if #available(iOS 13, *) {
            self.startSignInWithAppleFlow()
        } else {
            let alert = UIAlertController(title: "Fonction non disponible", message: "Merci de mettre à jour votre iPhone vers iOS 13 minimum pour bénéficié de cette fonctionnalité.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true)
        }
    }
    
    func emailLogIn(withEmail email: String, password: String, from viewController: UIViewController, isForCredential: Bool) {
        self.viewController = viewController
        self.isForCredential = isForCredential
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        self.signIn(credential: credential)
    }
    
    func emailSignUp(withEmail email: String, password: String, from viewController: UIViewController) {
        self.viewController = viewController
        Auth.auth().createUser(withEmail: email, password: password, completion: authCompletion)
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    fileprivate var currentNonce: String?
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        //        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension FirebaseUtils: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            self.signIn(credential: credential)
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        self.delegate?.firebaseAuthError(error: error)
    }
}

extension FirebaseUtils: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        print("LOL")
        
        return ASPresentationAnchor(frame: CGRect.zero)
    }
}

extension FirebaseUtils: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.delegate?.firebaseAuthError(error: error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        self.signIn(credential: credential)
    }
}

extension FirebaseUtils {
    func signIn(credential: AuthCredential) {
        if isForCredential {
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: authCompletion)
        } else {
            Auth.auth().signIn(with: credential, completion: authCompletion)
        }
    }
    
    func authCompletion(_ authResult: AuthDataResult?, _ error: Error?) {
        if let error = error {
            self.delegate?.firebaseAuthError(error: error)
        } else if let result = authResult {
            self.delegate?.firebaseAuth(result: result)
        } else {
            
        }
    }
}
