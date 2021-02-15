//
//  UserService.swift
//  Platoun
//
//  Created by Flavian Mary on 11/02/2021.
//  Copyright © 2021 Flavian Mary. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseCrashlytics

final class UserService {
    static let shared = UserService()
    
    private init() {}

    let DB_REF: Firestore = Firestore.firestore()

    let USER_DB_REF: CollectionReference = Firestore.firestore().collection("users")

    
    func getUser(userId: String, completion: @escaping (UserV2?)->Void) {
        let userQuery = USER_DB_REF.document(userId)
                
        userQuery.getDocument { (snapshot, error) in
            
            if let data = snapshot?.data() {
                let user = UserV2(userId: userId, userInfo: data)
                completion(user)
            } else {
                completion(nil)
            }
            
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
    
    func getLikePost(userId: String, completion: @escaping ([ProductVote])->Void) {
        let userQuery = USER_DB_REF.document(userId).collection("likes")
        userQuery.getDocuments { (snapshot, error) in
            
            let likes = (snapshot?.documents ?? []).compactMap { snapshot in
                ProductVote(postId: snapshot.documentID, userInfo: snapshot.data())
            }
            
            completion(likes)
            
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
    
    func getSurkiffPost(userId: String, completion: @escaping ([ProductVote])->Void) {
        let userQuery = USER_DB_REF.document(userId).collection("surkiffs")
        userQuery.getDocuments { (snapshot, error) in
            
            let likes = (snapshot?.documents ?? []).compactMap { snapshot in
                ProductVote(postId: snapshot.documentID, userInfo: snapshot.data())
            }
            
            completion(likes)
            
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
    
    func getMyPost(userId: String, completion: @escaping ([ProductVote])->Void) {
        let userQuery = USER_DB_REF.document(userId).collection("postCreated")
        userQuery.getDocuments { (snapshot, error) in
            
            let likes = (snapshot?.documents ?? []).compactMap { snapshot in
                ProductVote(postId: snapshot.documentID, userInfo: snapshot.data())
            }
            
            completion(likes)
            
            if let error = error {
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
}
