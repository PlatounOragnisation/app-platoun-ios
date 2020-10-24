//
//  ManageUserUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 20/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics

class ManageUserUtils {
    
    let viewController: UIViewController
    init(in vc: UIViewController) {
        viewController = vc
    }
    
    
    private func choseName(user: User, completion: @escaping ()->Void) {
        UIKitUtils.requestAlert(in: viewController, message: "Choissez un nom :") { name in
            self.nameIsOk(name: name) { (nameValid, retry) in
                guard nameValid else {
                    if retry {
                        self.choseName(user: user, completion: completion); return
                    } else {
                        completion(); return
                    }
                }
                self.changeName(user: user, name: name) { hasError in
                    guard hasError else { completion(); return }
                    
                    self.changeName(user: user, name: name) { _ in
                        completion()
                    }
                }
                return
            }
        }
    }
        
    func nameIsOk(name: String, completion: @escaping ((nameValid:Bool, retry: Bool))->Void){
        var errorMessage: String?
        if name.contains(" ") {
            errorMessage = "Votre nom ne doit pas contenir d'espace"
        } else if name.contains("\n") {
            errorMessage = "Votre nom ne doit pas contenir plusieurs lignes"
        } else if name.count <= 3 {
            errorMessage = "Votre nom doit avoir plus de 4 charactères"
        } else if name.count > 25 {
            errorMessage = "Votre nom doit avoir moins de 25 charactères"
        }
        
        if let errorMessage = errorMessage {
            self.show(text: errorMessage) {
                completion((nameValid:false, retry: true))
            }
        } else {
            self.checkNameDoesntExist(name: name, completion: completion)
        }
        
    }
    
    
    private func checkNameDoesntExist(name: String, completion: @escaping ((nameValid:Bool, retry: Bool))->Void) {
        FirestoreUtils.search(name: name) { nameExist in
            
            var messageError: String?
            let result: (nameValid:Bool, retry: Bool)
            switch nameExist {
            case true:
                messageError = "Votre nom est déjà pris merci d'en choisir un nouveau"
                result = (nameValid: false, retry: true)
            case false:
                result = (nameValid: true, retry: false)
            default:
                messageError = "Un problème est survenue lors de la vérification de la disponibilité de votre nom. Un nom aléatoire vous sera attribué et vous pourrez le changer plus tard"
                result = (nameValid: false, retry: false)
            }
            
            if let messageError = messageError {
                self.show(text: messageError) {
                    completion(result)
                }
            } else {
                completion(result)
            }
        }
    }
    
    private func definedNameRandom() -> String {
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        return "PlatounUser-\(timestamp)\(Int.random(in: 0..<100))"
    }
    
    func viabilise(user: User, completion: @escaping ()->Void) {
        self.makeUserCorrect(user: user) { _ in
            completion()
        }
    }
    
    func afterConnexion(completion: @escaping ()->Void) {
        guard let user = Auth.auth().currentUser else {
            AuthenticationLogout()
            return
        }
        
        
        self.checkUser(user: user) { result in
            switch result {
            case .success(let isCreation):
                if isCreation {
                    self.choseName(user: user) {
                        completion()
                    }
                } else {
                    completion()
                }
            case .failure(_):
                AuthenticationLogout()
            }
        }
    }
    
    //name is Valid
    func afterCreation(name: String?, completion: @escaping ()->Void) {
        guard let user = Auth.auth().currentUser else {
            AuthenticationLogout()
            return
        }
        
        let definedName = (name ?? "").isEmpty ? nil : name
        
        self.checkUser(user: user, definedName: definedName) { result in
            switch result {
            case .success(let isCreation):
                if isCreation && definedName == nil {
                    self.choseName(user: user) {
                        completion()
                    }
                } else {
                    completion()
                }
            case .failure(let error):
                self.errorDuringCreation(error: error)
            }
        }
    }
    
    
    // For all connection
    private func makeUserCorrect(user: User, completion: @escaping (Result<Void, Error>)->Void) {
        
        self.userIsSaved(with: user.uid) { resultUserIsSaved in
            switch resultUserIsSaved {
            case .success(let platounUser):
                if let pUser = platounUser {
                    self.updateToken(user: pUser)
                    
                    if user.displayName != pUser.displayName {
                        let name = pUser.displayName ?? self.definedNameRandom()
                        self.saveUserName(user: user, name: name) { resultSaveUserName in
                            completion(.success(()))
                        }
                    } else {
                        completion(.success(()))
                    }
                } else {
                    if user.displayName != nil {
                        self.createUserInDB(user: user, name: user.displayName!) { resultCreateUserInDB in
                            switch resultCreateUserInDB {
                            case .success:
                                completion(.success(()))
                            case .failure(let e):
                                completion(.failure(e))
                            }
                        }
                    } else {
                        let name = self.definedNameRandom()
                        self.saveUserName(user: user, name: name) { resultSaveUserName in
                            switch resultSaveUserName {
                            case .success:
                                self.createUserInDB(user: user, name: name) { resultCreateUserInDB in
                                    switch resultCreateUserInDB {
                                    case .success:
                                        completion(.success(()))
                                    case .failure(let e):
                                        completion(.failure(e))
                                    }
                                }
                            case .failure(let e):
                                completion(.failure(e))
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // For Connexion by social network
    private func checkUser(user: User, definedName: String? = nil, completion: @escaping (Result<Bool, Error>)->Void){
        self.userIsSaved(with: user.uid) { resultUserIsSaved in
            switch resultUserIsSaved {
            case .success(let platounUser):
                if let pUser = platounUser {
                    self.updateToken(user: pUser)
                    
                    if user.displayName != pUser.displayName {
                        let name = pUser.displayName ?? self.definedNameRandom()
                        self.saveUserName(user: user, name: name) { resultSaveUserName in
                            completion(.success(false))
                        }
                    } else {
                        completion(.success(false))
                    }
                } else {
                    let name = definedName ?? self.definedNameRandom()
                    self.saveUserName(user: user, name: name) { resultSaveUserName in
                        switch resultSaveUserName {
                        case .success:
                            self.createUserInDB(user: user, name: name) { resultCreateUserInDB in
                                switch resultCreateUserInDB {
                                case .success:
                                    completion(.success(true))
                                case .failure(let e):
                                    completion(.failure(e))
                                }
                            }
                        case .failure(let e):
                            completion(.failure(e))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func userIsSaved(with uid: String, completion: @escaping (Result<PlatounUser?, Error>)->Void) {
        FirestoreUtils.Users.getUser(uid: uid, forCreation: true) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                if error == DocumentReferenceError.DocumentDoesntExist {
                    completion(.success(nil))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func changeName(user: User, name: String, completion: @escaping (_ hasError: Bool)->Void) {
        let request = user.createProfileChangeRequest()
        request.displayName = name
        
        request.commitChanges { error in
            if let err = error {
                Crashlytics.crashlytics().record(error: err)
                completion(true)
                return
            }
            FirestoreUtils.Users.saveUser(uid: user.uid, name: name)
            completion(false)
        }
    }
    
    private func saveUserName(user: User, name: String, completion: @escaping (Result<Void,Error>)->Void) {
        let request = user.createProfileChangeRequest()
        request.displayName = name
        request.commitChanges { error in
            if let err = error {
                Crashlytics.crashlytics().record(error: err)
                completion(.failure(err))
            } else {
                FirestoreUtils.saveName(name: name)
                completion(.success(()))
            }
        }
    }
    
    private func createUserInDB(user: User, name: String, completion: @escaping (Result<Void,Error>)->Void) {
        let platounUser = PlatounUserComplet(uid: user.uid, fcmToken: UserDefaults.standard.FCMToken, displayName: name, photoUrl: user.photoURL?.absoluteString)
        FirestoreUtils.Users.createUser(user: platounUser) { result in
            if case .failure(let err) = result {
                completion(.failure(err)); return
            }
            Interactor.shared.updateToken(userId: user.uid, token: UserDefaults.standard.FCMToken ?? "")
            completion(.success(()))
        }
    }
    
    private func updateToken(user: PlatounUser) {
        if let fcmToken = UserDefaults.standard.FCMToken {
            Interactor.shared.updateToken(userId: user.uid, token: fcmToken)
            if fcmToken != user.fcmToken {
                FirestoreUtils.Users.saveUser(uid: user.uid, fcmToken: fcmToken)
            }
        }
    }
    
    private func errorDuringCreation(error: Error?) {
        Auth.auth().currentUser?.delete()
        AuthenticationLogout()
        self.show(text: "Une erreur est survenue durant la créeation de votre profil, merci de réessayer.") {}
    }
    
    private func show(text: String, completion: @escaping ()->Void) {
        UIKitUtils.showAlert(in: viewController, message: text) {
            completion()
        }
    }
}
