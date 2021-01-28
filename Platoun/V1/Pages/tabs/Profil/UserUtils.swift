//
//  UserUtils.swift
//  Platoun
//
//  Created by Flavian Mary on 04/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrashlytics
import SDWebImage

class UserUtils {
    typealias CompletionResult = (_ success: Bool, _ message: String)->Void
    
    let user: User
    let authentication: Authentication
    
    init?(user: User){
        self.user = user
        do {
            self.authentication = try user.getAuthentication()
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return nil
        }
    }
    
    
    enum ModificationType {
        case name(String)
        case email(String)
        case photo(UIImage)
        
        var type: Int {
            switch self {
            case .name:
                return 0
            case .email:
                return 1
            case .photo:
                return 2
            }
        }
    }
    
    func start(modifications: [ModificationType],from viewController: UIViewController, completion: @escaping CompletionResult) {

        let sema = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global()
        
        queue.async {
            if case .email(let newEmail) = modifications.first(where: { $0.type == 1 }) {
                guard let _ = try? self.updateEmail(newEmail, sema: sema) else {
                    completion(false,"Une erreur est survenue lors de votre changement d'email.")
                    return
                }
            }
            
            var newUrlImage: URL?
            if case .photo(let newPhoto) = modifications.first(where: { $0.type == 2 }) {
                guard let newUrl = try? self.uploadImage(newPhoto, sema: sema) else {
                    completion(false, "Une erreur est survenue lors de l'upload de votre photo.")
                    return
                }
                newUrlImage = newUrl
            }
            
            var newName: String?
            if case .name(let name) = modifications.first(where: { $0.type == 0 }) {
                newName = name
            }
            
            
            let needUpdateAuthUser = newName != nil || newUrlImage != nil
            
            guard needUpdateAuthUser else {
                completion(true, "Votre email a bien été modifié.")
                return
            }
            
            let oldName = self.user.displayName
            let oldPhoto = self.user.photoURL?.absoluteString
            
            let request = self.user.createProfileChangeRequest()
            request.updateName(newName)
            request.updatePhoto(newUrlImage)
            guard let _ = try? request.saveChange(sema: sema) else {
                let fullUpdate = newUrlImage != nil && newName != nil
                let complement = fullUpdate
                    ? "nom et de photo"
                    : (newUrlImage != nil ? "photo" : "nom")
                completion(false, "Une erreur est survenue lors de votre changement de \(complement).")
                return
            }
            
            let name = newName ?? (self.user.displayName ?? "")
            let url = newUrlImage ?? self.user.photoURL
            
            guard let _ = try? self.updateDatabase(oldName: oldName, oldPhoto: oldPhoto, name: name, url: url, sema: sema) else {
                completion(false, "Une erreur est survenue lors de la mise à jour de vos posts et commentaires. Il se peut que certains possèdent votre ancienne image et/ou votre ancien nom.")
                return
            }
            
            completion(true, "Toutes vos informations ont bien été mis à jours.")
        }
    }
    
    private func updateDatabase(oldName: String?, oldPhoto: String?, name: String, url: URL?, sema: DispatchSemaphore) throws {
        if oldName == name && oldPhoto == url?.absoluteString {
            return
        }

        guard let _ = try? FirestoreUtils.Users.saveUser(uid: self.user.uid, name: name, photo: url?.absoluteString ?? "", sema: sema) else {
            throw ActionError.error
        }
        
        guard let _ = try? FirestoreUtils.Posts.updatePosts(uid: self.user.uid, name: name, photo: url?.absoluteString ?? "", sema: sema) else {
            throw ActionError.error
        }
        
        guard let _ = try? FirestoreUtils.Comments.updateComments(uid: self.user.uid, name: name, photo: url?.absoluteString ?? "", sema: sema) else {
            throw ActionError.error
        }
        
        return
    }
    
    
    private func uploadImage(_ newImage: UIImage, sema: DispatchSemaphore) throws -> URL {
        
        var newUrlString: URL?
        StorageUtils.uploadImageProfil(image: newImage, userId: self.user.uid) { result in
            switch result {
            case .success(let urlString):
                SDImageCache.shared.removeImageFromDisk(forKey: urlString.absoluteString)
                SDImageCache.shared.removeImageFromMemory(forKey: urlString.absoluteString)
                newUrlString = urlString
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
            }
            sema.signal()
        }
        sema.wait()
        
        
        if let newUrl = newUrlString {
            return newUrl
        } else {
            throw ActionError.error
        }
    }
    
    
    private func updateEmail(_ newEmail: String, sema: DispatchSemaphore) throws {
        var success: Bool = false
        self.user.updateEmail(to: newEmail) { (error) in
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
                success = false
            } else {
                success = true
            }
            sema.signal()
        }
        sema.wait()
        
        if success {
            return
        } else {
            throw ActionError.error
        }
    }
}

fileprivate enum ActionError: Error {
    case error
}

fileprivate extension UserProfileChangeRequest {
    func updateName(_ name: String?) {
        guard let name = name else { return }
        self.displayName = name
    }
    
    func updatePhoto(_ url: URL?) {
        guard let url = url else { return }
        self.photoURL = url
    }
    
    func saveChange(sema: DispatchSemaphore) throws {
        var success: Bool = false
        self.commitChanges {
            if let error = $0 {
                Crashlytics.crashlytics().record(error: error)
                success = false
            } else {
                success = true
            }
            sema.signal()
        }
        
        sema.wait()
        
        if success {
            return
        } else {
            throw ActionError.error
        }
    }
}
