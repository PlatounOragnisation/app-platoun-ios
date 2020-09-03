//
//  AppleSignIn.swift
//  Platoun
//
//  Created by Flavian Mary on 03/09/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import Foundation
import AuthenticationServices
import CryptoKit


class AppleSignInUtils: NSObject {
    typealias SignInResult = Result<(String,String),Error>
    fileprivate static var instance: AppleSignInUtils?
    
    static func shared(from viewController: UIViewController, completion: @escaping (SignInResult)->Void) -> AppleSignInUtils {
        instance = instance ?? AppleSignInUtils(from: viewController, callBack: completion)
        instance?.callBack = completion
        instance?.viewController = viewController
        return instance!
    }
    
    fileprivate var callBack: (SignInResult)->Void
    fileprivate var viewController: UIViewController
    
    fileprivate init(from viewController: UIViewController, callBack: @escaping (SignInResult)->Void) {
        self.callBack = callBack
        self.viewController = viewController
    }
    
    fileprivate var currentNonce: String?
    
    func signIn() {
        if #available(iOS 13, *) {
            self.startSignInWithAppleFlow()
        } else {
            let alert = UIAlertController(title: "Fonction non disponible", message: "Merci de mettre à jour votre iPhone vers iOS 13 minimum pour bénéficié de cette fonctionnalité.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true)
        }
    }
    
    @available(iOS 13, *)
    private func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
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
}

extension AppleSignInUtils: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
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
            
            self.callBack(SignInResult.success((idTokenString, nonce)))
            
//            // Initialize a Firebase credential.
//            let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                      idToken: idTokenString,
//                                                      rawNonce: nonce)
//            // Sign in with Firebase.
//            self.signIn(credential: credential)
        default:
            break
        }
    }
    
    @available(iOS 13.0, *)
    func AppleSignIn(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        self.callBack(SignInResult.failure(error))
    }
    
}



extension AppleSignInUtils: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.viewController.view.window!
    }
}
